extends Node
# My Firebass API Key
const API_KEY := "AIzaSyBvsNBz_HEsQDZVE1hLEhYeJ8ZeXpqnMuE"

const SEND_URL:="https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=%s" % API_KEY
const CFM_URL:="https://identitytoolkit.googleapis.com/v1/accounts:update?key=%s" % API_KEY

func sendRegMail(tkn: String, http: HTTPRequest)->void:
	var body := {
		"requestType" : "VERIFY_EMAIL",
		"idToken" : tkn
	}
	http.request(SEND_URL, [], false, HTTPClient.METHOD_POST, to_json(body))
	var result := yield(http, "request_completed") as Array
	print("Result from Reg Email: ")
	print(result)
