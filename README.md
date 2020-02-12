[![CircleCI](https://circleci.com/gh/ministryofjustice/fb-user-filestore/tree/master.svg?style=svg)](https://circleci.com/gh/ministryofjustice/fb-user-filestore/tree/master)

# fb-user-filestore

## Environment Variables

Form Builder API service that allows files to be stored and retrieved. This
Rails app is an internal API to handle file storage with AWS S3

The following environment variables are required for this application to work
correctly.

- `SERVICE_TOKEN_CACHE_ROOT_URL` - http/https of location of service token cache Rails application
- `MAX_IAT_SKEW_SECONDS` - max time a signed JWT is allowed to deviate from time of submission
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `AWS_S3_BUCKET_NAME` - Bucket name to upload to and download from
- `KEY_ENCRYPTION_IV` - must be 16 characters - initialisation vector to determine the key (filename) for the uploaded file
- `ENCRYPTION_KEY` - The AES-256-CBC key used for encryption / decryption
- `ENCRYPTION_IV` - Initialization Vector (IV) for the AES-256-CBC

## Making API calls

To craft calls to the API the below script can be used from the rails console.
This will hit the API with a valid request to upload a file and then download
the same file.

```ruby
require Rails.root.join('spec/support/request_helpers.rb')

payload = json_request(Base64.strict_encode64(File.open(Rails.root.join('spec/fixtures/files/image.png')).read));
jwt_payload = { iat: Time.now.to_i, checksum: Digest::SHA256.hexdigest(payload.to_json) }
`curl -X POST --header "x-access-token: #{JWT.encode(jwt_payload, 'service-token', 'HS256')}" --header "Content-Type: application/JSON" --data '#{payload.to_json}' http://localhost:3000/service/some-service/user/some-user`

# response => "{\"url\":\"/service/some-service/user/some-user/28d-e71c352d0852ab802592a02168877dc255d9c839a7537d91efed04a5865549c1\",\"size\":173,\"type\":\"image/png\",\"date\":1554734786}"

payload = { encrypted_user_id_and_token: '12345678901234567890123456789012', iat: Time.now.to_i }
jwt_payload = { iat: Time.now.to_i, checksum: Digest::SHA256.hexdigest(payload.to_json) }
query_string_payload = Base64.strict_encode64(payload.to_json)
response = `curl -X GET --header "x-access-token: #{JWT.encode(jwt_payload, 'service-token', 'HS256')}" http://localhost:3000/service/some-service/user/some-user/28d-e71c352d0852ab802592a02168877dc255d9c839a7537d91efed04a5865549c1?payload=#{query_string_payload}`

hash = JSON.parse(response)

File.open('/tmp/out', 'wb') {|f| f.write Base64.strict_decode64(hash['file']) }
```

## Building docker image

You can build a docker image with the following command

```sh
docker build .
```
