# Call Bulletinboard-Ads App With Postman (REST Client)

Postman is a Google Chrome app for interacting with HTTP APIs. It has a friendly GUI for constructing requests and reading responses.

<img src="images/postman_overview.png" width="700" />

## Step 1: Open Postman
- Open Chromium browser
- Open a new tab
- Click "Apps"

  <img src="images/chromium_apps.png" width="400" />
- Click "Postman"
  - **Hint:** if this your first startup you will be asked to register - just skip this
    <img src="images/postman_signup.png" width="700" />
- Select `GET` and paste the URL to the `/health` endpoint of your **Bulletinboard-Ads** App. (**Hint**: You must use the HTTP protocol).
- Send the request. As response `{"status":"UP"}` should be returned.
  <img src="images/postman_get_rooturl.png" />

## Step 2: Get All Advertisements
- In Postman, extend the URL of your app with `/ads/api/v1/ads/` to `http://bulletinboard--<your-name-space>.ingress.<your-trainings-cluster>.k8s-train.shoot.canary.k8s-hana.ondemand.com/ads/ads/api/v1/ads`.

- Send the request. As response an empty array should be returned. **Remark**: We do not have created any advertisements so far - so there are no ones

## Step 3: Create New Advertisement
- In Postman, select `POST` instead of `GET` as request method
- On tab `Body`
  - Select the radio button `raw`
  - Instead of `Text` select `JSON (application/json)` from the drop down list
    <img src="images/postman_post_options.png" />
  - Enter below JSON in the text field
    - **Hint:** Replace `<place-holder>` accordingly
```
{
	"title":"new-advertisement-from-<your-user-id>-1",
	"price": "140",
	"contact": "test@sepp.com",
	"currency" : "EUR"
}
```
- Send the request, it should succeed.
  - As response you should get the created advertisement
    <img src="images/postman_post_response.png" />
- Create another advertisement with a different title, e.g. `"new-advertisement-from-<your-userid>-2`"

## Step 4: Get All Advertisements
- In Postman, switch back to `GET` as request method
- Send the request and check whether your advertisements are returned
