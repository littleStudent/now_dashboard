const { json, send } = require('micro')
const nowClient = require('now-client')
const match = require('micro-match');

var now;

module.exports = async function (req, res) {
    const {id} = match('/:id', req.url);
    now = nowClient(`${req.headers['authorization']}`)

    res.setHeader('Content-Type', 'application/json')
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Credentials', 'true');
    res.setHeader('Access-Control-Allow-Methods', 'GET,HEAD,OPTIONS,POST,PUT,DELETE');
    res.setHeader('Access-Control-Allow-Headers', 'Authorization, Access-Control-Allow-Headers, Access-Control-Allow-Methods, Origin,Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers');
    if (req.method == 'POST') {
        const data = await json(req);
        try {
            console.log(data.alias);
            console.log(id);
            response = await now.createAlias(id, data.alias)
            send(res, 200, response);
        } catch (err) {
            console.log(err)
            send(res, 500, err);
        }
    } else {
        return ''
    }
}