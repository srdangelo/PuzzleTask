part of simple_http_server;

List<Map> trialOrder = [{"order_id":"1", "trial_order":"1,2,3,4,5,6,7,8"},
                        {"order_id":"2", "trial_order":"2,1,3,4,5,6,7,8"},
                        {"order_id":"3", "trial_order":"1,2,3,4,5,6,7,8"},
                        {"order_id":"4", "trial_order":"1,2,3,4,5,6,7,8"}];


List<Map> imageSets = [{"trial_id": "1", "image_set": "plaid1, plaid2, plaid3, plaid4, plaid5, plaid6, plaid7, plaid8, plaid9","trial_difficulty": "Hard"},
                       {"trial_id": "2", "image_set": "rainbow1,rainbow2,rainbow3,rainbow4,rainbow5,rainbow6,rainbow7,rainbow8,rainbow9","trial_difficulty": "Easy"},
                       {"trial_id": "3", "image_set": "3,2,3,4,5,6,7,8,9","trial_difficulty": "Easy"},
                       {"trial_id": "4", "image_set": "4,2,3,4,5,6,7,8,9","trial_difficulty": "Hard"},
                       {"trial_id": "5", "image_set": "5,2,3,4,5,6,7,8,9","trial_difficulty": "Easy"},
                       {"trial_id": "6", "image_set": "6,2,3,4,5,6,7,8,9","trial_difficulty": "Hard"},
                       {"trial_id": "7", "image_set": "7,2,3,4,5,6,7,8,9","trial_difficulty": "Easy"},
                       {"trial_id": "8", "image_set": "8,2,3,4,5,6,7,8,9","trial_difficulty": "Hard"}];

void startTrials(var order){
  for(var imgset in imageSets){
    if  (imgset['trial_id'] == order.value){
      for(var imageId in imgset['image_set'].split(',')){
        print(imageId);
      }
    }
  }
}