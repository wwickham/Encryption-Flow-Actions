@isTest
private class CryptoHashGeneratorTest {

    static final String INPUT_STRING = 'teststring123';

    //Method that returns the hashed input
    static List<CryptoHashGenerator.HashResponse> hashInputString(String providedSalt){

        List<CryptoHashGenerator.HashRequest> hashRequestList = new List<CryptoHashGenerator.HashRequest>();
        CryptoHashGenerator.HashRequest hashRequest = new CryptoHashGenerator.HashRequest();
        hashRequest.input = INPUT_STRING;
        if(String.isNotBlank(providedSalt)) {
            hashRequest.salt = providedSalt;
        }
        hashRequestList.add(hashRequest);

        List<CryptoHashGenerator.HashResponse> responseList = new List<CryptoHashGenerator.HashResponse>();

        responseList = CryptoHashGenerator.processRequest(hashRequestList);
        
        return responseList;
    }

    @isTest
    static void testHashSuccess() {
        List<CryptoHashGenerator.HashResponse> responseList = new List<CryptoHashGenerator.HashResponse>();
        
        responseList = hashInputString('');
        
        CryptoHashGenerator.HashResponse response = responseList[0];

        System.debug('testHashSuccess response.hash: ' + response.hash);
        System.debug('testHashSuccess response.salt: ' + response.salt);

        //Response should have exactly one encrypted result that does not contain the error message
        System.assertEquals(1, responseList.size());
        System.assertEquals(false, response.hash.contains('Error'));
    }

    @isTest
    static void testHashSuccessSalted() {
        List<CryptoHashGenerator.HashResponse> responseList = new List<CryptoHashGenerator.HashResponse>();
        
        responseList = hashInputString('12345');
        
        CryptoHashGenerator.HashResponse response = responseList[0];

        System.debug('testHashSuccess response.hash: ' + response.hash);
        System.debug('testHashSuccess response.salt: ' + response.salt);

        //Response should have exactly one encrypted result that does not contain the error message
        System.assertEquals(1, responseList.size());
        System.assertEquals(false, response.hash.contains('Error'));
    }
}