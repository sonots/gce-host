# 0.4.0 (2016/12/02)

Enhancements:

* Support role levels more than 3 by ROLE_MAX_DEPTH configuration

# 0.3.4 (2016/11/28)

Enhancements

* Support /etc/default/gce-host as default config file location for Ubuntu

# 0.3.3 (2016/11/26)

Enhancements

* Get auth_method from type in credentials if it exists

# 0.3.2 (2016/11/25)

Enhancements

* raise if project is not given

# 0.3.1 (2016/11/25)

Enhancements

* Get project_id from credentials['client_email'] for a service account json

# 0.3.0 (2016/11/25)

Changes

* Change AUTH_METHOD 'json_key' to 'service_account'

Enhancements

* Support AUTH_METHOD 'authorized_user'

# 0.2.1 (2016/11/25)

Changes

* Environment variable GOOGLE_CREDENTIAL_FILE => GOOGLE_APPLICATION_CREDENTIALS

# 0.2.0 (2016/11/25)

Enhancements:

* Try reading credential file from `~/.config/gcloud/legacy_credentials/#{service_account}/adc.json`

# 0.1.3 (2016/11/24)

Enhancements:

* Support ~ (home directory) in GCE_HOST_CONFIG_FILE and GOOGLE_CREDENTIAL_FILE

# 0.1.2 (2016/11/24)

yanked

# 0.1.1 (2016/11/24)

Enhancements:

* Add machine_type to show

# 0.1.0 (2016/11/18)

first version

