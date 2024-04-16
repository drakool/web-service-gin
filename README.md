# Web-service-gin
a simple go application that uses go's gin framework to list albums. 

## Env loading
This app uses the library [godotenv](github.com/joho/godotenv) to load environment variables from .env files


## Adding Github Actions
To use the new GitHub Actions auth action, you need to set up and configure Workload Identity Federation by creating a Workload Identity Pool and Workload Identity Provider:

### Github Actions workflow
1. Artifact build stage: use language-specific tooling (gradle, sbt, npm, etc.) to build an application artifact
2. Packaging stage: bundle the application artifact with any other required components/dependencies
3. Containerization stage: create a container image containing the application package
4. Release creation stage: use the Cloud Deploy GitHub Action to create a release of the built container image
5. Rollout stages, 1..n: progress the release through a series of GKE,  Cloud Run, or Anthos target environments

### Artifact build
```
actions/setup-go@v4
```

### Release Creation stage
Uses the github action auth and create cloud deploy release
```
google-github-actions/auth@v2

google-github-actions/create-cloud-deploy-release
```

### Creating workload identity pool
```
gcloud iam workload-identity-pools create "my-identity-pool" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --display-name="gh actions pool"
```

### Get the unique identifier of that pool
```
gcloud iam workload-identity-pools describe "${WORKLOAD_IDENTITY_POOL}" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --format="value(name)"
```


### Creating workload identity provider
```
gcloud iam workload-identity-pools providers create-oidc "my-identity-provider" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --workload-identity-pool="my-identity-pool" \
  --display-name="gh actions provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.aud=assertion.aud" \
  --issuer-uri="https://token.actions.githubusercontent.com"
```

### Create the corresponding service account

Allow authentications from the Workload Identity Provider to impersonate the desired Service Account:


```
gcloud iam service-accounts add-iam-policy-binding "my-service-account@${PROJECT_ID}.iam.gserviceaccount.com" \
  --project="${PROJECT_ID}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/1234567890/locations/global/workloadIdentityPools/my-identity-pool/attribute.repository/my-org/my-repo"
```

  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \


or better yet 
```
gcloud iam service-accounts add-iam-policy-binding "${SERVICE_ACCOUNT_EMAIL}" \
  --project="${PROJECT_ID}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/654873593958/locations/global/workloadIdentityPools/my-identity-pool/providers/my-identity-provider"
```