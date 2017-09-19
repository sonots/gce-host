# 0.5.4 (2017/09/19)

Fixes:

* Fix --instance-id option was not working

# 0.5.3 (2017/09/19)

Fixes:

* Fix --all option did not show all options

# 0.5.2 (2017/06/15)

Changes:

* The incompatiblity issues of google-api-ruby-client v0.12.0 was resolved (reverted) in v0.13.0.
  * So, revert the support of google-api-ruby-client v0.12.0 to keep codes clean.
  * And, drop support of google-api-ruby-client v0.12.0.

# 0.5.1 (2017/06/14)

Enhancements:

* Support google-api-ruby-client >= v0.12.0

Fixes:

* Fix to use `Config.status: ['running']` instead of `state: ['running']`

# 0.5.0 (2017/05/20)

Enhancements:

* Support google-api-ruby-client >= v0.11.0

# 0.4.4 (2017/05/20)

Fixes:

* Fix to support multile roles and roleNs with command line arguments as
  * gce-host --role foo:a,bar:b
  * gce-host --role1 foo,bar --role2 a,b

# 0.4.3 (2017/01/20)

Enhancements:

* cli: sort by hostname

# 0.4.2 (2016/12/08)

Enhancements:

* Support /etc/google/auth/application_default_credentials.json

# 0.4.1 (2016/12/02)

Fixes:

* Fix role matching for when --role1 was not specified

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

