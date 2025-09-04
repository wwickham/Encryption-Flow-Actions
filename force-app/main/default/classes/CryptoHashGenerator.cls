global without sharing class CryptoHashGenerator {
    @InvocableMethod(label='Generate SHA-512 Hash' description='Generates a secure hash using the SHA-512 algorithm.')
    global static List<HashResponse> processRequest(List<HashRequest> requestList) {
        List<HashResponse> responseList = new List<HashResponse>();
        //Invocable methods must take a list input
        for (HashRequest request : requestList) {
            try {
                //Salt
                String salt;
                if(String.isNotBlank(request.salt)) {
                    salt = request.salt;
                } else {
                    Integer saltLength = 16; // 16 bytes = 128-bit salt
                    String saltString = '';

                    for (Integer i = 0; i < saltLength; i++) {
                        // Get a random int and constrain it to 0–255
                        Integer randomByte = Math.mod(Crypto.getRandomInteger(), 256);
                        if (randomByte < 0) randomByte += 256; // ensure positive
                        saltString += String.fromCharArray(new List<Integer>{randomByte});
                    }

                    Blob saltBlob = Blob.valueOf(saltString);
                    String saltHex = EncodingUtil.convertToHex(saltBlob);

                    salt = saltHex;
                }

                String saltedData = request.input + salt;

                Blob blobData = Blob.valueOf(saltedData);

                Blob hashBlob = Crypto.generateDigest('SHA-512', blobData);
                String hashHex = EncodingUtil.convertToHex(hashBlob);
                responseList.add(new HashResponse(hashHex, salt));
            } catch (Exception e) {
                responseList.add(new HashResponse('Error: ' + e.getMessage(), ''));
            }
        }
        return responseList;
    }

    //These variables recieve inputs from the flow
    global class HashRequest {
        @InvocableVariable(required=true label='Input' description='The input string to generate a secure hash for.')
        public String input;

        @InvocableVariable(required=false label='Salt' description='Random data used to make each hash unique. Not required for generating a new hash.')
        public String salt;
    }

    //The output of the flow action
    global class HashResponse {
        @InvocableVariable
        public String hash;

        @InvocableVariable
        public String salt;

        public HashResponse(String hash, String salt) {
            this.hash = hash;
            this.salt = salt;
        }
    }
}