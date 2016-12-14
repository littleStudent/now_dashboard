const { send } = require('micro')
const request = require("es6-request");

module.exports = async function (req, res) {
    res.setHeader('Content-Type', 'application/json')
    res.setHeader("Access-Control-Allow-Origin", "*");
    res.setHeader("Access-Control-Allow-Credentials", "true");
    res.setHeader("Access-Control-Allow-Methods", "GET,HEAD,OPTIONS,POST,PUT,DELETE");
    res.setHeader("Access-Control-Allow-Headers", "Authorization, Access-Control-Allow-Headers, Access-Control-Allow-Methods, Origin,Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers");

    if (req.headers['access-control-request-method']) {
        send(res, 200, {});
        return;
    }
    return request.get("https://api.zeit.co/now/aliases")
        .headers({
            'Authorization': `Bearer ${req.headers['authorization']}`,
            "Accept": "application/json"
        })
        .then(([body, res2]) => {
            if (res2.statusCode === 200) {
                send(res, 200, { token: req.headers['authorization'] });
            } else {
                send(res, 403, JSON.parse(body));
            }
        })
        .catch(x => {
            console.log(x);
            send(res, 403, x);
        });
}
