@isTest
private class EncryptDataTest {

    //The string to be encrypted. Also used to check against decryption result.
    static final String INPUT_STRING = 'teststring123';

    //Method that returns the encrypted input string
    static List<EncryptData.EncryptDecryptResponse> encryptInputString(String aesKey){
        //Create an encryption request
        List<EncryptData.EncryptDecryptRequest> encryptDecryptRequestList = new List<EncryptData.EncryptDecryptRequest>();
        EncryptData.EncryptDecryptRequest encryptDecryptRequest = new EncryptData.EncryptDecryptRequest();
        encryptDecryptRequest.input = INPUT_STRING;
        encryptDecryptRequest.key = aesKey;
        encryptDecryptRequest.encryptString = true;
        encryptDecryptRequestList.add(encryptDecryptRequest);

        //Prepare to recieve the encryption result
        List<EncryptData.EncryptDecryptResponse> responseList = new List<EncryptData.EncryptDecryptResponse>();

        //Run the encryption method
        responseList = EncryptData.processRequest(encryptDecryptRequestList);
        
        return responseList;
    }

    @isTest
    static void testEncryptSuccess() {
        //Generate an AES128 key
        String aesKey = EncodingUtil.base64Encode(Crypto.generateAesKey(128));
        //Prepare to store the encryption result
        List<EncryptData.EncryptDecryptResponse> responseList = new List<EncryptData.EncryptDecryptResponse>();
        
        responseList = encryptInputString(aesKey);
        
        EncryptData.EncryptDecryptResponse response = responseList[0];

        System.debug('testEncryptSuccess response.output: ' + response.output);

        //Response should have exactly one encrypted result that does not contain the error message
        System.assertEquals(1, responseList.size());
        System.assertEquals(false, response.output.contains('Error'));
    }

    @isTest
    static void testEncryptFailure() {
        //Create an invalid AES128 key
        String aesKey = 'badKey';
        //Prepare to store the encryption result
        List<EncryptData.EncryptDecryptResponse> responseList = new List<EncryptData.EncryptDecryptResponse>();
        
        responseList = encryptInputString(aesKey);

        EncryptData.EncryptDecryptResponse response = responseList[0];

        System.debug('testEncryptFailure response.output: ' + response.output);
	 
        //Response should have exactly 1 result that contains the error message
        System.assertEquals(1, responseList.size());
        System.assertEquals(true, response.output.contains('Error'));
    }

    @isTest
    static void testDecryptSuccess() {
        //Generate an AES128 key
        String aesKey = EncodingUtil.base64Encode(Crypto.generateAesKey(128));
        //Prepare to store the encryption result
        List<EncryptData.EncryptDecryptResponse> responseList = new List<EncryptData.EncryptDecryptResponse>();
        
        responseList = encryptInputString(aesKey);
        
        //Store the encrypted string response
        EncryptData.EncryptDecryptResponse encryptedResponse = responseList[0];

        //Create an decryption request
        List<EncryptData.EncryptDecryptRequest> decryptRequestList = new List<EncryptData.EncryptDecryptRequest>();
        EncryptData.EncryptDecryptRequest decryptRequest = new EncryptData.EncryptDecryptRequest();
        decryptRequest.input = encryptedResponse.output;
        decryptRequest.key = aesKey;
        decryptRequest.encryptString = false;
        decryptRequestList.add(decryptRequest);

        //Prepare to recieve the decryption result
        List<EncryptData.EncryptDecryptResponse> decryptResponseList = new List<EncryptData.EncryptDecryptResponse>();

        Test.startTest();

        decryptResponseList = EncryptData.processRequest(decryptRequestList);

        Test.stopTest();

        EncryptData.EncryptDecryptResponse response = decryptResponseList[0];

        System.debug('testDecryptSuccess response.output: ' + response.output);

        //Response should have exactly one decrypted result that does not contain the error message
        System.assertEquals(1, responseList.size());
        System.assertEquals(INPUT_STRING, response.output);
        System.assertEquals(false, response.output.contains('Error'));
    }

    @isTest
    static void testDecryptFailure() {
        //Generate an AES128 key
        String aesKey = EncodingUtil.base64Encode(Crypto.generateAesKey(128));
        //Prepare to store the encryption result
        List<EncryptData.EncryptDecryptResponse> responseList = new List<EncryptData.EncryptDecryptResponse>();
        
        responseList = encryptInputString(aesKey);
        
        //Store the encrypted string response
        EncryptData.EncryptDecryptResponse encryptedResponse = responseList[0];

        //Create an decryption request
        List<EncryptData.EncryptDecryptRequest> decryptRequestList = new List<EncryptData.EncryptDecryptRequest>();
        EncryptData.EncryptDecryptRequest decryptRequest = new EncryptData.EncryptDecryptRequest();
        decryptRequest.input = encryptedResponse.output;
        //Invalid AES128 Key
        decryptRequest.key = 'badKey';
        decryptRequest.encryptString = false;
        decryptRequestList.add(decryptRequest);

        //Prepare to recieve the decryption result
        List<EncryptData.EncryptDecryptResponse> decryptResponseList = new List<EncryptData.EncryptDecryptResponse>();

        Test.startTest();

        decryptResponseList = EncryptData.processRequest(decryptRequestList);

        Test.stopTest();

        EncryptData.EncryptDecryptResponse response = decryptResponseList[0];

        System.debug('testDecryptFailure response.output: ' + response.output);

        //Response should have exactly one result that contains the error message
        System.assertEquals(1, responseList.size());
        System.assertEquals(true, response.output.contains('Error'));
    }
}