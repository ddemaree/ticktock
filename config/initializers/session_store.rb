# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_tt_gamma_session',
  :secret      => 'b5c0f77104f06172f1ed407bf40f7f23f3897eae3e3374c807e95c1454a75da60b7244d46deade67268a074ee4aff4aa43f14223bb2b105fe35b5d01a154656c'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
