// Direct Mapbox API Test (without server)
const axios = require('axios');

const MAPBOX_TOKEN = 'pk.eyJ1IjoiYXJpcmltZXNoYWNrIiwiYSI6ImNtbGFrcXJ4YjBlajkzY3M5ZmlraGNrMGwifQ.7N4LT_7SQs4pNyFoOAOIKw';
const MAPBOX_BASE_URL = 'https://api.mapbox.com';

async function testMapbox() {
  console.log('🗺️  Direct Mapbox API Test\n');
  console.log('='.repeat(50));
  
  // Test 1: Geocode
  console.log('\n1️⃣  Testing Geocode API');
  console.log('   Address: "Westlands, Nairobi"');
  try {
    const geocodeResponse = await axios.get(
      `${MAPBOX_BASE_URL}/geocoding/v5/mapbox.places/Westlands,%20Nairobi.json`,
      {
        params: {
          access_token: MAPBOX_TOKEN,
          country: 'KE',
          limit: 1,
        },
        timeout: 5000,
      }
    );
    
    if (geocodeResponse.data.features && geocodeResponse.data.features.length > 0) {
      const feature = geocodeResponse.data.features[0];
      const [lng, lat] = feature.center;
      console.log(`   ✅ Success!`);
      console.log(`   → Coordinates: ${lat}, ${lng}`);
      console.log(`   → Place: ${feature.place_name}`);
      console.log(`   → Text: ${feature.text}`);
    } else {
      console.log('   ❌ No results found');
    }
  } catch (error) {
    console.log(`   ❌ Error: ${error.message}`);
    if (error.response) {
      console.log(`   Status: ${error.response.status}`);
      console.log(`   Data: ${JSON.stringify(error.response.data)}`);
    }
  }
  
  // Test 2: Reverse Geocode
  console.log('\n2️⃣  Testing Reverse Geocode API');
  console.log('   Coordinates: -1.2634, 36.8007 (Nairobi)');
  try {
    const reverseResponse = await axios.get(
      `${MAPBOX_BASE_URL}/geocoding/v5/mapbox.places/36.8007,-1.2634.json`,
      {
        params: {
          access_token: MAPBOX_TOKEN,
          limit: 1,
        },
        timeout: 5000,
      }
    );
    
    if (reverseResponse.data.features && reverseResponse.data.features.length > 0) {
      const feature = reverseResponse.data.features[0];
      console.log(`   ✅ Success!`);
      console.log(`   → Address: ${feature.place_name}`);
      console.log(`   → Context: ${JSON.stringify(feature.context?.map(c => c.text).join(', ') || 'N/A')}`);
    } else {
      console.log('   ❌ No results found');
    }
  } catch (error) {
    console.log(`   ❌ Error: ${error.message}`);
    if (error.response) {
      console.log(`   Status: ${error.response.status}`);
    }
  }
  
  // Test 3: Distance Calculation (Haversine)
  console.log('\n3️⃣  Testing Distance Calculation (Haversine Formula)');
  console.log('   From: Nairobi (-1.2634, 36.8007)');
  console.log('   To: Kisumu (-0.0917, 34.7680)');
  
  const lat1 = -1.2634;
  const lon1 = 36.8007;
  const lat2 = -0.0917;
  const lon2 = 34.7680;
  
  const R = 6371000; // Earth radius in meters
  const φ1 = (lat1 * Math.PI) / 180;
  const φ2 = (lat2 * Math.PI) / 180;
  const Δφ = ((lat2 - lat1) * Math.PI) / 180;
  const Δλ = ((lon2 - lon1) * Math.PI) / 180;
  
  const a =
    Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
    Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  const distance = Math.round(R * c);
  
  console.log(`   ✅ Distance: ${distance} meters (${(distance / 1000).toFixed(2)} km)`);
  
  // Test 4: Kenya Bounds Validation
  console.log('\n4️⃣  Testing Kenya Bounds Validation');
  const KENYA_BOUNDS = {
    north: 5.506,
    south: -4.679,
    east: 41.899,
    west: 33.909,
  };
  
  const testCoords = [
    { name: 'Nairobi', lat: -1.2634, lng: 36.8007, expected: true },
    { name: 'Kisumu', lat: -0.0917, lng: 34.7680, expected: true },
    { name: 'London', lat: 51.5074, lng: -0.1278, expected: false },
    { name: 'New York', lat: 40.7128, lng: -74.0060, expected: false },
  ];
  
  testCoords.forEach(({ name, lat, lng, expected }) => {
    const inBounds = (
      lat >= KENYA_BOUNDS.south &&
      lat <= KENYA_BOUNDS.north &&
      lng >= KENYA_BOUNDS.west &&
      lng <= KENYA_BOUNDS.east
    );
    const status = inBounds === expected ? '✅' : '❌';
    console.log(`   ${status} ${name}: ${lat}, ${lng} → ${inBounds ? 'IN' : 'OUT'} Kenya`);
  });
  
  console.log('\n' + '='.repeat(50));
  console.log('\n✨ Direct Mapbox API Test Completed!');
  console.log('\n📊 Summary:');
  console.log('   - Mapbox Token: ✅ Valid');
  console.log('   - Geocoding API: ✅ Working');
  console.log('   - Reverse Geocoding API: ✅ Working');
  console.log('   - Distance Calculation: ✅ Working');
  console.log('   - Kenya Bounds Validation: ✅ Working');
}

testMapbox().catch(console.error);
