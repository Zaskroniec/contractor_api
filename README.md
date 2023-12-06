# Contractor API

## Requirements
- Ruby 3.2.2
- Postgres 15.3

## Setup

- clone repo
- install dependencies `bundle install`
- create env file `cp example.envrc .envrc` and change according to your needs and load them to your session
- create db and load schema `rails db:setup`
- run tests `rails test`
- run server `rails s`

## Endpoints

### Show contract

Request

```bash
curl -i http://localhost:3000/contracts/{id}
```

Response 200

```json
{
  "data":{
    "user_id":1,
    "contract_number":"N00001",
    "average_weekly_hours":"30.5h",
    "hourly_wage":"15.99€",
    "updated_at":"2023-12-06T10:56:35Z",
    "created_at":"2023-12-06T10:56:35Z"
  }
}
```

### Create contract

Request

```bash
curl -X POST -H "Content-Type: application/json" -d '{"contract": {"start_at": "2023-12-13", "end_at": "2023-12-14", "wage_cents": 1599, "wage_currency": "EUR", "user_id": 1, "average_weekly_hours": 30.5}}' -i http://localhost:3000/contracts
```

Response 201

```json
{
  "data":{
    "user_id":1,
    "contract_number":"N00001",
    "average_weekly_hours":"30.5h",
    "hourly_wage":"15.99€",
    "updated_at":"2023-12-06T10:56:35Z",
    "created_at":"2023-12-06T10:56:35Z"
  }
}
```

### Update contract

Request

```bash
curl -X PATCH -H "Content-Type: application/json" -d '{"contract": {}}' -i http://localhost:3000/contracts/{id}
```

Response 200

```json
{
  "data":{
    "user_id":1,
    "contract_number":"N00001",
    "average_weekly_hours":"30.5h",
    "hourly_wage":"15.99€",
    "updated_at":"2023-12-06T10:56:35Z",
    "created_at":"2023-12-06T10:56:35Z"
  }
}
```

### Delete contract

Request

```bash
curl -X DELETE -i http://localhost:3000/contracts/{id}
```

Response 204

### Archive contracts

Reqesut

```bash
curl -X POST -H "Content-Type: multipart/form-data" -F "import=@{path_to_csv_file}" -i http://localhost:3000/contracts/archive
```

Response 200