const { send } = require('micro')
const nowClient = require('now-client')

module.exports = async function (req, res) {
    const now = nowClient(`${req.headers['authorization']}`)
    res.setHeader('Content-Type', 'application/json')
    res.setHeader("Access-Control-Allow-Origin", "*");
    res.setHeader("Access-Control-Allow-Credentials", "true");
    res.setHeader("Access-Control-Allow-Methods", "GET,HEAD,OPTIONS,POST,PUT,DELETE");
    res.setHeader("Access-Control-Allow-Headers", "Authorization, Access-Control-Allow-Headers, Access-Control-Allow-Methods, Origin,Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers");

    if (req.method == 'OPTIONS') {
        return ""
    }

    if (req.method == 'GET') {
        try {
            response = await now.getAliases()
            send(res, 200, response);
        } catch (err) {
            console.error(err)
            send(res, 500, err);
        }
    }
}