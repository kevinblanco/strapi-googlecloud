# 🚀 Strapi on Google Cloud Platform Sample App

This repository contains the codebase for "Strapi CMS on Google Cloud Platform: The Definitive Guide". 

I'm a Google Developer Expert in Google Cloud Platform. Today,[In this article I guide you](https://kevinblanco.dev/strapi-cms-on-google-cloud-platform-the-definitive-guide-part-1) through the entire process of deploying Strapi on GCP using Google App Engine, Google Cloud SQL, Google Cloud Storage with continuous integration/delivery using Google Cloud Build, from zero to production.

### `Running Locally`

- node v 18.20 + 
- npm install
- npm run build
- npm run develop

## Deploying with Terraform

In case you want to skip setting up all the required Google Cloud architecture you can use the Terraform file included in this repo, just make sure to create a `service-account.json` with the service account JSON credentials that has access to yout GCP project, then run: 

```
terraform apply
```
And it will generate all the archicture elements Strapi needs to run using the parameters and values you entered in the Terraform prompt. 

## 📚 Learn more

- [Youtube Tutorial](https://www.youtube.com/@KevinBlancoZ) - App Engine Instance
- [Step by Step Guide](https://kevinblanco.dev/strapi-cms-on-google-cloud-platform-the-definitive-guide-part-1) - kevinblanco.dev