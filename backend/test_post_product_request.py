import requests, json
url = 'http://127.0.0.1:3000/purifier-models/product-requests'
payload = {
  'purifier_model_id': 1,
  'mobile_number': '0999000111',
  'gmail': 'autotest+1@example.com',
  'password': 'testpass123'
}
headers = {'Content-Type':'application/json'}
try:
    r = requests.post(url, json=payload, headers=headers, timeout=10)
    print('STATUS', r.status_code)
    print(r.text)
except Exception as e:
    print('ERROR', e)
