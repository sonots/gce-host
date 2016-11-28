# gce-host

Search hosts on GCP GCE

## Installation

```
gem install gce-host
```

## How it works

This gems uses [metadata of GCE resources](https://cloud.google.com/compute/docs/storing-retrieving-metadata).
You can configure, but basically use `roles` key for roles.

You can manage roles of a host, and search hosts having a specified role using thease metadata with this gem.

## Configuration

You can write a configuration file located at `/etc/sysconfig/gce-host` or `/etc/default/gce-host` (You can configure this path by `GCE_HOST_CONFIG_FILE` environment variable), or as environment variables:

GOOGLE API parameters:

* **AUTH_METHOD (optional)**: Authentication method. Currently, `compute_engine`, `service_account`, `authorized_user`, and `application_default` is available. The default is `type` in `GOOGLE_APPLICATION_CREDENTIALS` if it exists, otherwise `compute_engine`.
* **GOOGLE_APPLICATION_CREDENTIALS (optional)**: Specify path of json credential file. The default is `~/.config/gcloud/application_default_credentials.json`.
* **GOOGLE_PROJECT (optional)**: Specify project name of your GCP account. The default is `project_id` in `GOOGLE_APPLICATION_CREDENTIALS` if it exists (typically, available in service acaccount json)

gce-host parameters:

* **ROLES_KEY (optional)**: GCE metadata keys used to express roles. The default is `roles`
  * You can assign multiple roles seperated by `ARRAY_VALUE_DELIMITER` (default: `,`)
  * Also, you can express levels of roles delimited by `ROLE_VALUE_DELIMITER` (default `:`)
  * Example: admin:ami, then `GCE::Host.new(role: 'admin:ami')` and also `GCE::Host.new(role1: 'admin')` returns this host
* **ROLE_VALUE_DELIMITER (optional)**: A delimiter to express levels of roles. Default is `:`
* **OPTIONAL_STRING_KEYS (optional)**: You may add optional non-array metadata keys. You can specify multiple keys like `service,status`. 
* **OPTIONAL_ARRAY_KEYS (optional)**: You may add optional array metadata keys. Array allows multiple values delimited by `ARRAY_VALUE_DELIMITER` (default: `,`)
* **ARRAY_VALUE_DELIMITER (optional)**: A delimiter to express array. Default is `,`
* **LOG_LEVEL (optional)**: Log level such as `info`, `debug`, `error`. The default is `info`. 

See [example.conf](./example/example.conf)

## Metadata Example

* **roles**: app:web,app:db
* **service**: awesome
* **status**: setup

## CLI Usage

### CLI Example

```
$ gce-host -j
{"hostname":"gce-host-db","roles":["foo","db:test"],"zone":"asia-northeast1-a","service":"gce-host","status":"active","tags":["master"],"instance_id":"4263858691219514807","private_ip_address":"10.240.0.6","public_ip_address":"104.198.89.55","creation_timestamp":"2016-11-22T06:51:04.650-08:00","state":"RUNNING"}
{"hostname":"gce-host-web","roles":["foo","web:test"],"zone":"asia-northeast1-a","service":"gce-host","status":"reserve","tags":["standby"],"instance_id":"8807276062743061943","private_ip_address":"10.240.0.5","public_ip_address":"104.198.87.6","creation_timestamp":"2016-11-22T06:51:04.653-08:00","state":"RUNNING"}
```

```
$ gce-host
gce-host-db
gce-host-web
```

```
$ gce-host --role1 db
gce-host-db
```

```
$ gce-host --role web:test
gce-host-web
```

```
$ gce-host --pretty-json
[
  {
    "hostname": "gce-host-db",
    "roles": [
      "foo",
      "db:test"
    ],
    "zone": "asia-northeast1-a",
    "service": "gce-host",
    "status": "active",
    "tags": [
      "master"
    ],
    "instance_id": "4263858691219514807",
    "private_ip_address": "10.240.0.6",
    "public_ip_address": "104.198.89.55",
    "creation_timestamp": "2016-11-22T06:51:04.650-08:00",
    "state": "RUNNING"
  },
  {
    "hostname": "gce-host-web",
    "roles": [
      "foo",
      "web:test"
    ],
    "zone": "asia-northeast1-a",
    "service": "gce-host",
    "status": "reserve",
    "tags": [
      "standby"
    ],
    "instance_id": "8807276062743061943",
    "private_ip_address": "10.240.0.5",
    "public_ip_address": "104.198.87.6",
    "creation_timestamp": "2016-11-22T06:51:04.653-08:00",
    "state": "RUNNING"
  }
]
```

### CLI Help

```
$ bin/gce-host --help
Usage: gce-host [options]
        --hostname one,two,three     name or private_dns_name
    -r, --role one,two,three         role
        --r1, --role1 one,two,three  role1, the 1st part of role delimited by :
        --r2, --role2 one,two,three  role2, the 2st part of role delimited by :
        --r3, --role3 one,two,three  role3, the 3st part of role delimited by :
        --state one,two,three        filter with instance state (default: running)
    -a, --all                        list all hosts (remove default filter)
        --private-ip, --ip           show private ip address instead of hostname
        --public-ip                  show public ip address instead of hostname
    -i, --info                       show host info
    -j, --jsonl                      show host info in line delimited json
        --json                       show host info in json
        --pretty-json                show host info in pretty json
        --debug                      debug mode
    -h, --help                       show help
```

## Library Usage

### Library Example

```ruby
require 'gce-host'

hosts = GCE::Host.new(role: 'db:test')
hosts.each do |host|
  puts host
end
```

### Library Reference

See http://sonots.github.io/gce-host/frames.html.

## ChangeLog

See [CHANGELOG.md](CHANGELOG.md) for details.

## For Developers

### ToDo

* Use mock/stub to run test (currently, directly accessing to GCE)
* Should cache a result of list_instances in like 30 seconds?

### How to Run test

NOTE: Currently, mock is not supported yet. So, you have to create your own gcloud account, and instances.

Configure .env file as

```
AUTH_METHOD=service_account
GOOGLE_APPLICATION_CREDENTIALS=service_acount.json
GOOGLE_PROJECT=XXXXXXXXXXXXX
OPTIONAL_STRING_KEYS=service,status
OPTIONAL_ARRAY_KEYS=tags
```

Install terraform and run to create instances for tests

```
$ brew install terraform
$ env $(cat .env) terraform plan
$ env ($cat .env) terraform apply
```

Run test

```
$ bundle exec rspec
```

After working, destory instances by commenting out `terraform.tf` and apply.

### How to Release Gem

1. Update gem.version in the gemspec
2. Update CHANGELOG.md
3. git commit && git push
4. Run `bundle exec rake release`

### How to Update doc

1. Run `bundle exec yard`
2. git commit && git push

### Licenses

See [LICENSE](LICENSE)

