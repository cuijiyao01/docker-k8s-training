# Exercise: Bulletinboard
After completing this exercise you should
- understand the bulletin board domain incl. the role of a "premium user"
- know how to call the "Advertisements" microservice with the [REST](https://de.wikipedia.org/wiki/Representational_State_Transfer
) client

## Step 1: Push Application
You will now push the application to your dev space.

- If you have not yet pushed the app to your dev space, you need to do this first
  - **Hint:** you can look this up in the [Cloud Foundry CLI exercise](/General/Cloud_Basics/Exercise-CF_CLI.md)
- If the app has been successfully pushed, open a terminal and execute `cf apps`
  - **Hint:** make sure you are logged in targeting your dev space
- Copy the URL (route) to your app to the clipboard
<img src="images/cf_apps.png" />

## Step 2: Call App With Postman (REST Client)

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
- In Postman, extend the URL of your app with `/api/v1.0/ads/`
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
    "title" : "new-advertisement-from-<your-user-id>"
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
