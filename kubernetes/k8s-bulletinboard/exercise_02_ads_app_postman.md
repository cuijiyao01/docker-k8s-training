## Step 2: Call Ads App With Postman (REST Client)

Postman is a Google Chrome app for interacting with HTTP APIs. It has a friendly GUI for constructing requests and reading responses.

<img src="images/postman_overview.png" width="700" />

### Step 2.1: Open Postman
- Open Chromium browser
- Open a new tab
- Click "Apps"

  <img src="images/chromium_apps.png" width="400" />
- Click "Postman"
  - **Hint:** if this your first startup you will be asked to register - just skip this
    <img src="images/postman_signup.png" width="700" />
- Select `GET` and paste the URL to your app (**Hint**: You must use the HTTPS protocol)
- Send the request. As response `OK` should be returned
  <img src="images/postman_get_rooturl.png" />

### Step 2.2: Get All Advertisements
- In Postman, extend the URL of your app with `/ads/api/v1.0/ads/`
- Send the request. As response an empty array should be returned. **Remark**: We do not have created any advertisements so far - so there are no ones

### Step 2.3: Create New Advertisement
- In Postman, select `POST` instead of `GET` as request method
- On tab `Body`
  - Select the radio button `raw`
  - Instead of `Text` select `JSON (application/json)` from the drop down list
    <img src="images/postman_post_options.png" />
  - Enter below JSON in the text field
    - **Hint:** Replace `<place-holder>` accordingly
```
{
	"title":"new-advertisement-from-<your-user-id>-<number>",
	"price": "140",
	"contact": "sepp@seppderdepp.com",
	"currency" : "EUR"
}
```
- Send the request - it should fail with an error message telling you are not authorized
  - The reason is that only premium users are allowed to create new advertisements
  - As you remember, your ads microservice is using a central, shared users microservice that already has a premium user configured
- Select the tab `Headers`
  - Insert `User-Id` as `Header` and `42` as `Value` as new entry
  - **Hint:** The user with id 42 already exists in the central users microservice as premium user
    <img src="images/postman_post_headers.png" />
- Send the request, it should now succeed
  - As response you should get the created advertisement
    <img src="images/postman_post_response.png" />
- Create another advertisement with a different title, e.g. "new-advertisement-from-2-<your-userid>"

### Step 2.4: Get All Advertisements
- In Postman, switch back to `GET` as request method
- Send the request and check whether your advertisements are returned

## Step 3: Access App With Browser
Now, access the application using the browser.
- Open Chromium browser
- Open a new tab
- Paste the following URLs into the adress field and check the results.
  - REST API, Get All: `https://bulletinboard-ads-dev-<your-user-id>.cfapps.sap.hana.ondemand.com/api/v1.0/ads/`
  - REST API, Get Single: `https://bulletinboard-ads-dev-<your-user-id>.cfapps.sap.hana.ondemand.com/api/v1.0/ads/<advertisement-id>`
  - UI: `https://bulletinboard-ads-dev-<your-user-id>.cfapps.sap.hana.ondemand.com/static/index.html`
