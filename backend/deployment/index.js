const { send } = require('micro')
const nowClient = require('now-client')
const match = require('micro-match');

module.exports = async function (req, res) {
    const {id} = match('/:id', req.url);
    const now = nowClient(`${req.headers['authorization']}`)

    res.setHeader('Content-Type', 'application/json')
    res.setHeader("Access-Control-Allow-Origin", "*");
    res.setHeader("Access-Control-Allow-Credentials", "true");
    res.setHeader("Access-Control-Allow-Methods", "GET,HEAD,OPTIONS,POST,PUT,DELETE");
    res.setHeader("Access-Control-Allow-Headers", "Authorization, Access-Control-Allow-Headers, Access-Control-Allow-Methods, Origin,Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers");

    if (req.method == 'OPTIONS') {
        send(res, 200, "");
        return ""
    }

    try {
        if (req.method == 'GET') {
            response = await now.getDeployment(id)
            send(res, 200, response);
        } else if (req.method == 'DELETE') {
            response = await now.deleteDeployment(id)
            send(res, 200, response);
        } else {
            return ""
        }
    } catch (err) {
        console.error(err)
        send(res, 500, err);
    }
}
