import requests as r
base_url = "http://10.51.21.56:8080"
response=r.post(base_url+"/zabbix/screens.php?elementid=23")
print(response.status_code)
