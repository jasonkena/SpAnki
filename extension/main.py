import json
import urllib.request
import requests
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

# Use the application default credentials
# Use the application default credentials
cred = credentials.Certificate('')
firebase_admin.initialize_app(cred)

db = firestore.client()

server_url = ""

email = "castrojv@bc.edu"
user = db.collection("users").where("email", "==", email).get()
assert len(user) == 1
user = user[0]

requests.post(server_url, verify=False, json={"user_hash":user.id})

docs1 = user.reference.collection("docs").stream()
docs2 = user.reference.collection("photos").stream()

info = []
print(docs1)
for doc in docs1:
    new_words = doc.get('word')
    if len(new_words) > 0:
        info.append(new_words)
        print(info)

for doc2 in docs2:
    new_words = ''

    output = doc2.reference.collection('boxedCoords').stream()

    for thing in output:
        new_words = thing.get('word')
    if len(new_words) > 0:
        info.append(new_words)
        print(info)

eng_word_list = info
surviving_eng_words = []
definition_output_list = []
span_output_list = []
app_id = ""
app_key = ""

for word in eng_word_list:
    word = word.lower().strip()
    try:
        r2 = requests.get("https://www.dictionaryapi.com/api/v3/references/spanish/json/" + str(
            word) + "?")
        r2 = r2.json()
        start_of_parse = r2[0]['def'][0]['sseq'][0][0][1]['dt'][0][1]
        span_translation = start_of_parse.split('|')
        count = 0
        for item in span_translation:
            if len(span_translation) == 1:
                if 'bc' in item:
                    separate = span_translation[0].split("}")
                    span_output = separate[1]
                    if ',' in span_output:
                        arr = span_output.split(',')
                        span_output = arr[0]
                    span_output_list.append(span_output)
            else:
                if 'bc' in item:
                    span_output = str(span_translation[count + 1]).replace('}', '')
                    if ',' in span_output:
                        arr = span_output.split(',')
                        span_output = arr[0]
                    span_output_list.append(span_output)
                else:
                    count += 1

        url = "https://od-api.oxforddictionaries.com/api/v2/entries/en/" + str(word)
        r = requests.get(url, headers={"app_id": app_id, "app_key": app_key})
        r = r.json()
        definition = r['results'][0]['lexicalEntries'][0]['entries'][0]['senses'][0]['definitions'][0]
        definition_output_list.append(definition)

        surviving_eng_words.append(word)
    except:
        continue


def request(action, **params):
    return {'action': action, 'params': params, 'version': 6}


def invoke(action, **params):
    requestJson = json.dumps(request(action, **params)).encode('utf-8')
    response = json.load(urllib.request.urlopen(urllib.request.Request('http://localhost:8765', requestJson)))
    if len(response) != 2:
        raise Exception('response has an unexpected number of fields')
    if 'error' not in response:
        raise Exception('response is missing required error field')
    if 'result' not in response:
        raise Exception('response is missing required result field')
    return response['result']


result = invoke('deckNames')
if "Spanish Learning" not in result:
    invoke('createDeck', deck="Spanish Learning")

iteration = 0
print(span_output_list)
for output in range(len(span_output_list)):
    question = str(span_output_list[iteration]) + "- " + str(definition_output_list[iteration] + " {{c1::")
    answer = f"{surviving_eng_words[iteration]}"
    question += answer + " }}"
    note2 = {
            "deckName": "Spanish Learning",
            "modelName": "Cloze",
            "fields": {"Text": f"{question}", "Extra": "Great job!"},
            "tags": ['spanish']
            }
    invoke('addNote', note=note2)
    iteration += 1


iteration += 1
result = invoke('deckNames')
print(result)