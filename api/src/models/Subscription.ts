export enum SubscriptionTier {
  FREEMIUM = 'freemium',
  PREMIUM = 'premium',
  CLEANING = 'cleaning',
  LAUNDRY = 'laundry',
  PROPERTY_BOOKING = 'property_booking',
  COMBINED = 'combined',
}

export enum SubscriptionStatus {
  ACTIVE = 'active',
  EXPIRED = 'expired',
  CANCELLED = 'cancelled',
  TRIAL = 'trial',
}

export enum BillingPeriod {
  MONTHLY = 'monthly',
  ANNUAL = 'annual',
}

export interface Subscription {
  id: string;
  user_id: string;
  tier: SubscriptionTier;
  status: SubscriptionStatus;
  billing_period: BillingPeriod;
  auto_renew: boolean;
  trial_ends_at: Date | null;
  current_period_start: Date;
  current_period_end: Date;
  cancelled_at: Date | null;
  created_at: Date;
  updated_at: Date;
}

export interface SubscriptionFeature {
  id: string;
  subscription_id: string;
  feature: string;
  enabled: boolean;
  limit_value: number | null;
  created_at: Date;
}

export interface SubscriptionResponse {
  id: string;
  userId: string;
  tier: SubscriptionTier;
  status: SubscriptionStatus;
  billingPeriod: BillingPeriod;
  autoRenew: boolean;
  trialEndsAt: string | null;
  currentPeriodStart: string;
  currentPeriodEnd: string;
  cancelledAt: string | null;
  features: SubscriptionFeatureResponse[];
  createdAt: string;
  updatedAt: string;
}

export interface SubscriptionFeatureResponse {
  feature: string;
  enabled: boolean;
  limitValue: number | null;
}

export interface AvailableSubscription {
  tier: SubscriptionTier;
  name: string;
  description: string;
  billingPeriods: {
    period: BillingPeriod;
    price: number;
    currency: string;
  }[];
  features: string[];
  limits: Record<string, number | null>;
}

export interface UpgradeSubscriptionInput {
  tier: SubscriptionTier;
  billingPeriod: BillingPeriod;
}

export interface DowngradeSubscriptionInput {
  tier: SubscriptionTier;
}

export interface FeatureAccessResponse {
  hasAccess: boolean;
  limit?: number | null;
  used?: number;
  remaining?: number | null;
}
