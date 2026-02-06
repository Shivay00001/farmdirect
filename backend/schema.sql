-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- USERS TABLE
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  mobile VARCHAR(15) UNIQUE NOT NULL,
  email VARCHAR(255),
  name VARCHAR(255) NOT NULL,
  role VARCHAR(50) NOT NULL CHECK (role IN ('FARMER','RETAILER','DELIVERY','SUPPORT','ADMIN')),
  status VARCHAR(50) DEFAULT 'PENDING_VERIFICATION' CHECK (status IN ('PENDING_VERIFICATION','ACTIVE','SUSPENDED','DELETED')),
  language VARCHAR(10) DEFAULT 'en',
  profile_photo VARCHAR(500),
  rating DECIMAL(2,1) DEFAULT 0,
  total_ratings INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- FARMER PROFILES
CREATE TABLE IF NOT EXISTS farmer_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  state VARCHAR(100),
  district VARCHAR(100),
  village VARCHAR(100),
  aadhaar_number VARCHAR(20),
  farm_size DECIMAL,
  crops JSONB, -- array of crop names
  fpo_membership VARCHAR(255),
  bank_account_number VARCHAR(50),
  bank_ifsc VARCHAR(20),
  bank_holder_name VARCHAR(255),
  documents JSONB, -- array of document URLs
  verification_status VARCHAR(50) DEFAULT 'PENDING' CHECK (verification_status IN ('PENDING','VERIFIED','REJECTED')),
  verification_notes TEXT,
  verified_by UUID REFERENCES users(id),
  verified_at TIMESTAMP
);

-- RETAILER PROFILES
CREATE TABLE IF NOT EXISTS retailer_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  shop_name VARCHAR(255),
  gst_number VARCHAR(20),
  shop_address TEXT,
  shop_lat DECIMAL(10,8),
  shop_lng DECIMAL(11,8),
  shop_photo VARCHAR(500),
  business_type VARCHAR(50) CHECK (business_type IN ('KIRANA','RESTAURANT','HOTEL','WHOLESALE')),
  categories_interested JSONB
);

-- DELIVERY PARTNER PROFILES
CREATE TABLE IF NOT EXISTS delivery_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  vehicle_type VARCHAR(50) CHECK (vehicle_type IN ('BIKE','VAN','TRUCK')),
  vehicle_number VARCHAR(20),
  driving_license VARCHAR(50),
  documents JSONB,
  current_lat DECIMAL(10,8),
  current_lng DECIMAL(11,8),
  is_online BOOLEAN DEFAULT FALSE,
  total_deliveries INTEGER DEFAULT 0,
  total_distance DECIMAL DEFAULT 0
);

-- PRODUCTS
CREATE TABLE IF NOT EXISTS products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  farmer_id UUID REFERENCES users(id),
  name VARCHAR(255) NOT NULL,
  category VARCHAR(50) CHECK (category IN ('GRAINS','VEGETABLES','FRUITS','DAIRY','SPICES','OTHER')),
  quantity DECIMAL NOT NULL,
  unit VARCHAR(20),
  price_per_unit DECIMAL NOT NULL,
  min_order_qty DECIMAL,
  harvest_date DATE,
  quality_grade VARCHAR(50) CHECK (quality_grade IN ('A','B','C')),
  is_organic BOOLEAN DEFAULT FALSE,
  images JSONB,
  description TEXT,
  status VARCHAR(50) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE','SOLD_OUT','DELETED')),
  rating DECIMAL(2,1) DEFAULT 0,
  total_orders INTEGER DEFAULT 0,
  views INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- ORDERS
CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_number VARCHAR(20) UNIQUE NOT NULL,
  farmer_id UUID REFERENCES users(id),
  retailer_id UUID REFERENCES users(id),
  delivery_partner_id UUID REFERENCES users(id),
  product_id UUID REFERENCES products(id),
  quantity DECIMAL NOT NULL,
  unit_price DECIMAL NOT NULL,
  total_amount DECIMAL NOT NULL,
  platform_commission DECIMAL,
  delivery_fee DECIMAL,
  net_amount_to_farmer DECIMAL,
  status VARCHAR(50) DEFAULT 'PENDING' CHECK (status IN ('PENDING','ACCEPTED','REJECTED','PICKED_UP','IN_TRANSIT','DELIVERED','CANCELLED')),
  payment_status VARCHAR(50) DEFAULT 'PENDING' CHECK (payment_status IN ('PENDING','PAID','REFUNDED','FAILED')),
  payment_method VARCHAR(50) CHECK (payment_method IN ('COD','ONLINE','CREDIT')),
  pickup_address TEXT,
  delivery_address TEXT,
  pickup_lat DECIMAL(10,8),
  pickup_lng DECIMAL(11,8),
  delivery_lat DECIMAL(10,8),
  delivery_lng DECIMAL(11,8),
  distance DECIMAL, -- in km
  estimated_delivery TIMESTAMP,
  actual_delivery TIMESTAMP,
  rejection_reason TEXT,
  cancellation_reason TEXT,
  delivery_instructions TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- ORDER TRACKING
CREATE TABLE IF NOT EXISTS order_tracking (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID REFERENCES orders(id),
  status VARCHAR(50),
  location_lat DECIMAL(10,8),
  location_lng DECIMAL(11,8),
  notes TEXT,
  created_by UUID REFERENCES users(id),
  timestamp TIMESTAMP DEFAULT NOW()
);

-- PAYMENTS
CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID REFERENCES orders(id),
  razorpay_order_id VARCHAR(100),
  razorpay_payment_id VARCHAR(100),
  razorpay_signature VARCHAR(255),
  amount DECIMAL NOT NULL,
  currency VARCHAR(3) DEFAULT 'INR',
  status VARCHAR(50) CHECK (status IN ('PENDING','SUCCESS','FAILED','REFUNDED')),
  method VARCHAR(50), -- card, upi, netbanking
  payment_date TIMESTAMP,
  refund_amount DECIMAL,
  refund_date TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

-- TICKETS (Support)
CREATE TABLE IF NOT EXISTS tickets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ticket_number VARCHAR(20) UNIQUE NOT NULL,
  user_id UUID REFERENCES users(id),
  user_role VARCHAR(50),
  type VARCHAR(50) CHECK (type IN ('PAYMENT','QUALITY','DELIVERY','TECHNICAL','OTHER')),
  priority VARCHAR(50) DEFAULT 'MEDIUM' CHECK (priority IN ('LOW','MEDIUM','HIGH','CRITICAL')),
  subject VARCHAR(255),
  description TEXT,
  order_id UUID REFERENCES orders(id),
  status VARCHAR(50) DEFAULT 'OPEN' CHECK (status IN ('OPEN','IN_PROGRESS','RESOLVED','CLOSED')),
  assigned_to UUID REFERENCES users(id),
  escalated_to UUID REFERENCES users(id),
  resolution TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  resolved_at TIMESTAMP
);
