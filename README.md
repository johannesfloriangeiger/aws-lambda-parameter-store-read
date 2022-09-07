# AWS Lambda reading from Parameter Store example

## Setup

```
PROFILE=...
aws configure --profile $PROFILE
```

## Install

### Terraform

```
AWS_SDK_LOAD_CONFIG=1 AWS_PROFILE=$PROFILE terraform init
AWS_SDK_LOAD_CONFIG=1 AWS_PROFILE=$PROFILE terraform apply
```

### Lambda

```
zip lambda.zip index.js \
    && aws --profile $PROFILE \
        lambda update-function-code \
        --function-name get-parameter \
        --zip-file fileb://lambda.zip \
        --publish \
    && rm lambda.zip
```

## Test

```
aws --profile $PROFILE lambda invoke --function-name get-parameter out \
    && cat out | jq -r .Parameter.Value \
    && rm out
```

Outputs the Lambda execution result log and `value`, the value of the parameter `parameter`.