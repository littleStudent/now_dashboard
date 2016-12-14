# ▲ZEIT dashboard

The dashboard consists of some small microservices and a frontend application.
> Since the zeit API does not support CORS at the moment, all traffic is running through microservices deployed to now

All API calls point to the deployed backends below. 
> As soon as CORS is supported the backend microservices will be dropped

#### Deployed Backend APIs
* [authentication API](https://now.authentication.autcoding.com/)
* [deployments API](https://now.deployments.autcoding.com/)
* [deployment API](https://now.deployment.autcoding.com/)
* [aliases API](https://now.aliases.autcoding.com/)
* [deployments aliases API](https://now.deployments.aliases.autcoding.com/)
* [secrets API](https://now.secrets.autcoding.com/)

#### Deployed Frontend
* [frontend](https://nash.now.sh/)

# Deployment

1. run `now` for each microservice
2. point all urls to the deployed microservices
    * [Deployments](https://github.com/littleStudent/now_dashboard/blob/master/src/elm/Deployments/Rest.elm)
    * [Aliases](https://github.com/littleStudent/now_dashboard/blob/master/src/elm/Aliases/Rest.elm)
    * [Login](https://github.com/littleStudent/now_dashboard/blob/57eca8c1b42491c0897700f1a9722f27b68f584c/src/elm/Login/Rest.elm)
    * [Secrets](https://github.com/littleStudent/now_dashboard/blob/57eca8c1b42491c0897700f1a9722f27b68f584c/src/elm/Secrets/Rest.elm)
3. run `now --docker` for the frontend
