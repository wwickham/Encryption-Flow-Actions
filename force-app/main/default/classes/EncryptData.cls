global without sharing class EncryptData {
    @InvocableMethod(label='Encrypt or Decrypt String with AES128' description='Encrypts or decrypts a string using AES128 encryption')
    global static List<EncryptDecryptResponse> processRequest(List<EncryptDecryptRequest> requestList) {
        List<EncryptDecryptResponse> responseList = new List<EncryptDecryptResponse>();
        //Invocable methods must take a list input
        for (EncryptDecryptRequest request : requestList) {
            try {
                Blob key = EncodingUtil.base64Decode(request.key);
                if (request.encryptString) {
                    //Encryption
                    Blob data = Blob.valueOf(request.input);
                    Blob encryptedData = Crypto.encryptWithManagedIV('AES128', key, data);
                    String encryptedString = EncodingUtil.base64Encode(encryptedData);
                    //Have to encode the token to remove unsafe URL characters
                    String encodedURLToken = EncodingUtil.urlEncode(encryptedString, 'UTF-8');
                    responseList.add(new EncryptDecryptResponse(encodedURLToken));
                } else {
                    //Decryption
                    //Have to decode the input to convert from a URL encoded string to a valid token
                    String decodedURLToken = EncodingUtil.urlDecode(request.input, 'UTF-8');
                    Blob encryptedData = EncodingUtil.base64Decode(decodedURLToken);
                    Blob decryptedData = Crypto.decryptWithManagedIV('AES128', key, encryptedData);
                    String decryptedString = decryptedData.toString();
                    responseList.add(new EncryptDecryptResponse(decryptedString));
                }
            } catch (Exception e) {
                responseList.add(new EncryptDecryptResponse('Error: ' + e.getMessage()));
            }
        }
        return responseList;
    }

    //These variables recieve inputs from the flow
    global class EncryptDecryptRequest {
        @InvocableVariable(required=true label='Input' description='The input string to be encrypted or decrypted')
        public String input;
        @InvocableVariable(required=true label='Key' description='The AES key (base64 encoded) used for encryption/decryption')
        public String key;
        @InvocableVariable(required=true label='Encrypt Input?' description='Determines whether to encrypt or decrypt. True to encrypt, False to decrypt.')
        public Boolean encryptString;
    }

    //The output of the flow action
    global class EncryptDecryptResponse {
        @InvocableVariable
        public String output;

        public EncryptDecryptResponse(String output) {
            this.output = output;
        }
    }
}