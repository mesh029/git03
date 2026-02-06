import pool from '../config/database';
import { 
  Subscription, 
  SubscriptionTier, 
  SubscriptionStatus, 
  BillingPeriod,
  SubscriptionResponse,
  SubscriptionFeature,
  AvailableSubscription,
  UpgradeSubscriptionInput,
  DowngradeSubscriptionInput,
  FeatureAccessResponse,
} from '../models/Subscription';
import { NotFoundError, ValidationError } from '../utils/errors';

export class SubscriptionService {
  /**
   * Get all available subscription tiers with pricing and features
   */
  async getAvailableSubscriptions(): Promise<AvailableSubscription[]> {
    // Define available subscription tiers
    const subscriptions: AvailableSubscription[] = [
      {
        tier: SubscriptionTier.FREEMIUM,
        name: 'Freemium',
        description: 'Basic access with limited features',
        billingPeriods: [
          {
            period: BillingPeriod.MONTHLY,
            price: 0,
            currency: 'KES',
          },
        ],
        features: [
          'Basic platform access',
          'Up to 3 orders per month',
          'Basic property listings (for agents)',
          'Standard support',
        ],
        limits: {
          orders_per_month: 3,
          properties: null,
          analytics: 0,
        },
      },
      {
        tier: SubscriptionTier.PREMIUM,
        name: 'Premium',
        description: 'Unlimited access with premium features',
        billingPeriods: [
          {
            period: BillingPeriod.MONTHLY,
            price: 999,
            currency: 'KES',
          },
          {
            period: BillingPeriod.ANNUAL,
            price: 9999,
            currency: 'KES',
          },
        ],
        features: [
          'Unlimited orders',
          'Advanced property features (for agents)',
          'Priority support',
          'Analytics dashboard',
          'Advanced reporting',
        ],
        limits: {
          orders_per_month: null, // Unlimited
          properties: null,
          analytics: 1,
        },
      },
      {
        tier: SubscriptionTier.CLEANING,
        name: 'Cleaning Service',
        description: 'Unlimited cleaning orders',
        billingPeriods: [
          {
            period: BillingPeriod.MONTHLY,
            price: 499,
            currency: 'KES',
          },
        ],
        features: [
          'Unlimited cleaning orders',
          'Basic platform access',
        ],
        limits: {
          cleaning_orders_per_month: null,
          orders_per_month: 3,
        },
      },
      {
        tier: SubscriptionTier.LAUNDRY,
        name: 'Laundry Service',
        description: 'Unlimited laundry orders',
        billingPeriods: [
          {
            period: BillingPeriod.MONTHLY,
            price: 499,
            currency: 'KES',
          },
        ],
        features: [
          'Unlimited laundry orders',
          'Basic platform access',
        ],
        limits: {
          laundry_orders_per_month: null,
          orders_per_month: 3,
        },
      },
      {
        tier: SubscriptionTier.PROPERTY_BOOKING,
        name: 'Property Booking',
        description: 'Unlimited property bookings',
        billingPeriods: [
          {
            period: BillingPeriod.MONTHLY,
            price: 799,
            currency: 'KES',
          },
        ],
        features: [
          'Unlimited property bookings',
          'Basic platform access',
        ],
        limits: {
          property_bookings_per_month: null,
          orders_per_month: 3,
        },
      },
      {
        tier: SubscriptionTier.COMBINED,
        name: 'Combined Services',
        description: 'All services unlimited',
        billingPeriods: [
          {
            period: BillingPeriod.MONTHLY,
            price: 1499,
            currency: 'KES',
          },
          {
            period: BillingPeriod.ANNUAL,
            price: 14999,
            currency: 'KES',
          },
        ],
        features: [
          'Unlimited orders (all types)',
          'Advanced property features (for agents)',
          'Priority support',
          'Analytics dashboard',
        ],
        limits: {
          orders_per_month: null,
          properties: null,
          analytics: 1,
        },
      },
    ];

    return subscriptions;
  }

  /**
   * Get user's current active subscription
   */
  async getCurrentSubscription(userId: string): Promise<SubscriptionResponse | null> {
    const result = await pool.query(
      `SELECT * FROM subscriptions 
       WHERE user_id = $1 AND status IN ('active', 'trial')
       ORDER BY created_at DESC
       LIMIT 1`,
      [userId]
    );

    if (result.rows.length === 0) {
      return null;
    }

    const subscription = result.rows[0] as Subscription;
    const features = await this.getSubscriptionFeatures(subscription.id);

    return this.toSubscriptionResponse(subscription, features);
  }

  /**
   * Get subscription features
   */
  private async getSubscriptionFeatures(subscriptionId: string): Promise<SubscriptionFeature[]> {
    const result = await pool.query(
      'SELECT * FROM subscription_features WHERE subscription_id = $1',
      [subscriptionId]
    );

    return result.rows as SubscriptionFeature[];
  }

  /**
   * Upgrade user subscription
   */
  async upgradeSubscription(
    userId: string,
    input: UpgradeSubscriptionInput
  ): Promise<SubscriptionResponse> {
    // Validate tier exists
    const availableSubscriptions = await this.getAvailableSubscriptions();
    const tierExists = availableSubscriptions.some(s => s.tier === input.tier);
    
    if (!tierExists) {
      throw new ValidationError(`Invalid subscription tier: ${input.tier}`);
    }

    // Check if billing period is available for this tier
    const subscription = availableSubscriptions.find(s => s.tier === input.tier);
    const periodExists = subscription?.billingPeriods.some(p => p.period === input.billingPeriod);
    
    if (!periodExists) {
      throw new ValidationError(`Billing period ${input.billingPeriod} not available for tier ${input.tier}`);
    }

    // Cancel or expire current subscription
    await this.cancelCurrentSubscription(userId);

    // Create new subscription
    const now = new Date();
    const periodEnd = new Date(now);
    
    if (input.billingPeriod === BillingPeriod.MONTHLY) {
      periodEnd.setMonth(periodEnd.getMonth() + 1);
    } else {
      periodEnd.setFullYear(periodEnd.getFullYear() + 1);
    }

    // Check if tier offers trial
    const isPremium = input.tier === SubscriptionTier.PREMIUM || input.tier === SubscriptionTier.COMBINED;
    const trialEndsAt = isPremium ? new Date(now.getTime() + 14 * 24 * 60 * 60 * 1000) : null; // 14 days trial
    const status = trialEndsAt ? SubscriptionStatus.TRIAL : SubscriptionStatus.ACTIVE;

    const subscriptionResult = await pool.query(
      `INSERT INTO subscriptions (
        user_id, tier, status, billing_period, auto_renew,
        trial_ends_at, current_period_start, current_period_end
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      RETURNING *`,
      [
        userId,
        input.tier,
        status,
        input.billingPeriod,
        true,
        trialEndsAt,
        now,
        periodEnd,
      ]
    );

    const newSubscription = subscriptionResult.rows[0] as Subscription;
    
    // Create subscription features based on tier
    await this.createSubscriptionFeatures(newSubscription.id, input.tier);

    const features = await this.getSubscriptionFeatures(newSubscription.id);
    return this.toSubscriptionResponse(newSubscription, features);
  }

  /**
   * Downgrade user subscription
   */
  async downgradeSubscription(
    userId: string,
    input: DowngradeSubscriptionInput
  ): Promise<SubscriptionResponse> {
    // Validate tier
    if (input.tier !== SubscriptionTier.FREEMIUM) {
      throw new ValidationError('Can only downgrade to freemium tier');
    }

    // Cancel current subscription
    await this.cancelCurrentSubscription(userId);

    // Create freemium subscription
    const now = new Date();
    const periodEnd = new Date(now);
    periodEnd.setFullYear(periodEnd.getFullYear() + 100); // Freemium doesn't expire

    const subscriptionResult = await pool.query(
      `INSERT INTO subscriptions (
        user_id, tier, status, billing_period, auto_renew,
        current_period_start, current_period_end
      ) VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING *`,
      [
        userId,
        SubscriptionTier.FREEMIUM,
        SubscriptionStatus.ACTIVE,
        BillingPeriod.MONTHLY,
        false,
        now,
        periodEnd,
      ]
    );

    const newSubscription = subscriptionResult.rows[0] as Subscription;
    
    // Create freemium features
    await this.createSubscriptionFeatures(newSubscription.id, SubscriptionTier.FREEMIUM);

    const features = await this.getSubscriptionFeatures(newSubscription.id);
    return this.toSubscriptionResponse(newSubscription, features);
  }

  /**
   * Cancel current subscription
   */
  async cancelSubscription(userId: string): Promise<SubscriptionResponse> {
    const currentSubscription = await this.getCurrentSubscription(userId);
    
    if (!currentSubscription) {
      throw new NotFoundError('Subscription');
    }

    // Update subscription status to cancelled
    const result = await pool.query(
      `UPDATE subscriptions 
       SET status = $1, cancelled_at = $2, auto_renew = false
       WHERE id = $3
       RETURNING *`,
      [SubscriptionStatus.CANCELLED, new Date(), currentSubscription.id]
    );

    const subscription = result.rows[0] as Subscription;
    const features = await this.getSubscriptionFeatures(subscription.id);

    return this.toSubscriptionResponse(subscription, features);
  }

  /**
   * Cancel current active subscription (internal use)
   */
  private async cancelCurrentSubscription(userId: string): Promise<void> {
    await pool.query(
      `UPDATE subscriptions 
       SET status = $1, cancelled_at = $2
       WHERE user_id = $3 AND status = 'active'`,
      [SubscriptionStatus.CANCELLED, new Date(), userId]
    );
  }

  /**
   * Check if user has access to a feature
   */
  async checkFeatureAccess(
    userId: string,
    feature: string
  ): Promise<FeatureAccessResponse> {
    const subscription = await this.getCurrentSubscription(userId);
    
    if (!subscription) {
      // Default to freemium limits
      return this.getDefaultFeatureAccess(feature);
    }

    const featureRecord = subscription.features.find(f => f.feature === feature);
    
    if (!featureRecord || !featureRecord.enabled) {
      return {
        hasAccess: false,
        limit: null,
      };
    }

    // Check if there's a limit and get usage
    let used = 0;
    if (featureRecord.limitValue !== null) {
      // Convert ISO string back to Date for getFeatureUsage
      const periodStart = new Date(subscription.currentPeriodStart);
      used = await this.getFeatureUsage(userId, feature, periodStart);
    }

    const remaining = featureRecord.limitValue !== null 
      ? Math.max(0, featureRecord.limitValue - used)
      : null;

    return {
      hasAccess: true,
      limit: featureRecord.limitValue,
      used,
      remaining,
    };
  }

  /**
   * Get default feature access (freemium)
   */
  private getDefaultFeatureAccess(feature: string): FeatureAccessResponse {
    const defaults: Record<string, FeatureAccessResponse> = {
      orders_per_month: {
        hasAccess: true,
        limit: 3,
        used: 0,
        remaining: 3,
      },
      unlimited_orders: {
        hasAccess: false,
        limit: null,
      },
      analytics: {
        hasAccess: false,
        limit: null,
      },
      priority_support: {
        hasAccess: false,
        limit: null,
      },
    };

    return defaults[feature] || { hasAccess: false, limit: null };
  }

  /**
   * Get feature usage for current period
   */
  private async getFeatureUsage(
    userId: string,
    feature: string,
    periodStart: Date
  ): Promise<number> {
    if (feature === 'orders_per_month' || feature.includes('orders')) {
      const orderType = feature.includes('cleaning') ? 'cleaning' :
                        feature.includes('laundry') ? 'laundry' :
                        feature.includes('property') ? 'property_booking' : null;

      let query = `SELECT COUNT(*) as count FROM orders 
                   WHERE owner_id = $1 AND created_at >= $2`;
      const params: any[] = [userId, periodStart];

      if (orderType) {
        query += ' AND type = $3';
        params.push(orderType);
      }

      const result = await pool.query(query, params);
      return parseInt(result.rows[0].count, 10);
    }

    return 0;
  }

  /**
   * Create subscription features based on tier
   */
  private async createSubscriptionFeatures(
    subscriptionId: string,
    tier: SubscriptionTier
  ): Promise<void> {
    const features: Array<{ feature: string; enabled: boolean; limitValue: number | null }> = [];

    switch (tier) {
      case SubscriptionTier.FREEMIUM:
        features.push(
          { feature: 'orders_per_month', enabled: true, limitValue: 3 },
          { feature: 'unlimited_orders', enabled: false, limitValue: null },
          { feature: 'analytics', enabled: false, limitValue: null },
          { feature: 'priority_support', enabled: false, limitValue: null }
        );
        break;
      case SubscriptionTier.PREMIUM:
      case SubscriptionTier.COMBINED:
        features.push(
          { feature: 'orders_per_month', enabled: true, limitValue: null },
          { feature: 'unlimited_orders', enabled: true, limitValue: null },
          { feature: 'analytics', enabled: true, limitValue: null },
          { feature: 'priority_support', enabled: true, limitValue: null }
        );
        break;
      case SubscriptionTier.CLEANING:
        features.push(
          { feature: 'cleaning_orders_per_month', enabled: true, limitValue: null },
          { feature: 'orders_per_month', enabled: true, limitValue: 3 }
        );
        break;
      case SubscriptionTier.LAUNDRY:
        features.push(
          { feature: 'laundry_orders_per_month', enabled: true, limitValue: null },
          { feature: 'orders_per_month', enabled: true, limitValue: 3 }
        );
        break;
      case SubscriptionTier.PROPERTY_BOOKING:
        features.push(
          { feature: 'property_bookings_per_month', enabled: true, limitValue: null },
          { feature: 'orders_per_month', enabled: true, limitValue: 3 }
        );
        break;
    }

    for (const feature of features) {
      await pool.query(
        `INSERT INTO subscription_features (subscription_id, feature, enabled, limit_value)
         VALUES ($1, $2, $3, $4)`,
        [subscriptionId, feature.feature, feature.enabled, feature.limitValue]
      );
    }
  }

  /**
   * Convert database subscription to response format
   */
  private toSubscriptionResponse(
    subscription: Subscription,
    features: SubscriptionFeature[]
  ): SubscriptionResponse {
    return {
      id: subscription.id,
      userId: subscription.user_id,
      tier: subscription.tier,
      status: subscription.status,
      billingPeriod: subscription.billing_period,
      autoRenew: subscription.auto_renew,
      trialEndsAt: subscription.trial_ends_at?.toISOString() || null,
      currentPeriodStart: subscription.current_period_start.toISOString(),
      currentPeriodEnd: subscription.current_period_end.toISOString(),
      cancelledAt: subscription.cancelled_at?.toISOString() || null,
      features: features.map(f => ({
        feature: f.feature,
        enabled: f.enabled,
        limitValue: f.limit_value,
      })),
      createdAt: subscription.created_at.toISOString(),
      updatedAt: subscription.updated_at.toISOString(),
    };
  }

  /**
   * Ensure user has a subscription (create freemium if none exists)
   */
  async ensureUserSubscription(userId: string): Promise<SubscriptionResponse> {
    let subscription = await this.getCurrentSubscription(userId);
    
    if (!subscription) {
      // Create default freemium subscription
      const now = new Date();
      const periodEnd = new Date(now);
      periodEnd.setFullYear(periodEnd.getFullYear() + 100);

      const result = await pool.query(
        `INSERT INTO subscriptions (
          user_id, tier, status, billing_period, auto_renew,
          current_period_start, current_period_end
        ) VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING *`,
        [
          userId,
          SubscriptionTier.FREEMIUM,
          SubscriptionStatus.ACTIVE,
          BillingPeriod.MONTHLY,
          false,
          now,
          periodEnd,
        ]
      );

      const newSubscription = result.rows[0] as Subscription;
      await this.createSubscriptionFeatures(newSubscription.id, SubscriptionTier.FREEMIUM);
      
      const features = await this.getSubscriptionFeatures(newSubscription.id);
      subscription = this.toSubscriptionResponse(newSubscription, features);
    }

    return subscription;
  }
}

export const subscriptionService = new SubscriptionService();
