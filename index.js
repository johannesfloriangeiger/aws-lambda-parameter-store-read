const ssm = new (require('aws-sdk/clients/ssm'))()

exports.handler = async (event) => {
    return await ssm.getParameter({ Name: '/parameter' }).promise()
}