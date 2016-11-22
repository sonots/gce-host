# How to run test

NOTE: Currently, mock is not supported yet. So, you have to create your own AWS account, and instances.

Configure .env file as

```
AUTH_METHOD=json_key
JSON_KEYFILE=example/your-project-000.json
ROLES_LABEL=roles
ROLE_LABEL_DELIMITER=:
OPTIONAL_STRING_LABELS=service,status
OPTIONAL_ARRAY_LABELS=tags
ARRAY_LABEL_DELIMITER=,
LOG_LEVEL=info
STATUS=state
```

GCE instance tags must be configured as followings:

```
[
  {
    hostname: test
    loles: admin:admin,test
    service: test
    status: reserve
    tags: standby
  }
  {
    hostname: isucon4
    roles: isucon4:qual
    service: isucon4
    status: active
    tags: master
  }
]
```
