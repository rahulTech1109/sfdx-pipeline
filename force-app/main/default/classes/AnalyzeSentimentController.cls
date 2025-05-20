public with sharing class AnalyzeSentimentController {
    @AuraEnabled
    public static void analyzeAndUpdateProduct(String productId) {
        
        // Check if the productId is valid and the user has access to the Product2 object
        List<Product2> products = [
            SELECT Id
            FROM Product2
            WHERE Id = :productId
            LIMIT 1
        ];
        
        if (products.isEmpty()) {
            throw new AuraHandledException('Invalid productId or insufficient permissions.');
        }
        
        // Query the ProductReview entity with aggregation
        AggregateResult[] reviews = [
            SELECT
            Overall_Sentiment_Type__c sentiment,count(Id) sentimentCount
            FROM Product_Review__c
            WHERE Product__c = :productId
            GROUP BY Overall_Sentiment_Type__c
            HAVING Overall_Sentiment_Type__c != null
        ];
        
        // Process the aggregated results to get the required values
        Decimal avgPScore = 0;
        Decimal avgNeuScore = 0;
        Decimal avgNScore = 0;
        
        if (!reviews.isEmpty()) {
            for(AggregateResult review : reviews){
                if(review.get('sentiment') == 'positive')
                    avgPScore = (Decimal)review.get('sentimentCount');
                else if(review.get('sentiment') == 'neutral')
                    avgNeuScore = (Decimal)review.get('sentimentCount');
                else if(review.get('sentiment') == 'negative')
                    avgNScore = (Decimal)review.get('sentimentCount');
            } 
        }
        
        // Check object-level permissions
        if (Schema.sObjectType.Product2.isUpdateable()) {
            Schema.SObjectType productSchema = Schema.getGlobalDescribe().get('Product2');
            Map<String, Schema.SObjectField> fieldMap = productSchema.getDescribe().fields.getMap();
            
            // Check field-level permissions
            Boolean hasEditPermissionOnPositiveSentiment = fieldMap.get('Aggregated_Positive_Sentiment__c').getDescribe().isUpdateable();
            Boolean hasEditPermissionOnNeutralSentiment = fieldMap.get('Aggregated_Neutral_Sentiment__c').getDescribe().isUpdateable();
            Boolean hasEditPermissionOnNegativeSentiment = fieldMap.get('Aggregated_Negative_Sentiment__c').getDescribe().isUpdateable();
            Boolean hasEditPermissionOnLastAnalyzedOn = fieldMap.get('Sentiment_Last_Analyzed_On__c').getDescribe().isUpdateable();
            
            if (hasEditPermissionOnPositiveSentiment && hasEditPermissionOnNeutralSentiment && hasEditPermissionOnNegativeSentiment && hasEditPermissionOnLastAnalyzedOn) {
                // Proceed with fetching and updating the product record
                Product2 product = [SELECT Id, Aggregated_Positive_Sentiment__c, Aggregated_Neutral_Sentiment__c, Aggregated_Negative_Sentiment__c, Sentiment_Last_Analyzed_On__c FROM Product2 WHERE Id = :productId LIMIT 1];
                product.Aggregated_Positive_Sentiment__c = avgPScore.setScale(0);
                product.Aggregated_Neutral_Sentiment__c = avgNeuScore.setScale(0);
                product.Aggregated_Negative_Sentiment__c = avgNScore.setScale(0);
                product.Sentiment_Last_Analyzed_On__c = System.now();
                
                update product;
            } else {
                // Handle the case where the user does not have edit permissions on the necessary fields
                System.debug('User does not have edit permissions on one or more required fields.');
            }
        } else {
            // Handle the case where the user does not have edit permissions on the Product2 object
            System.debug('User does not have edit permission on Product2 object.');
        }
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Product_Review__c> getProductReviews(Id productId) {
        return [
            SELECT Id, Review__c, Overall_Sentiment_Type__c, Overall_Sentiment_Score__c
            FROM Product_Review__c
            WHERE Product__c = :productId 
            LIMIT 500
        ];
    }
    
    @AuraEnabled
    public static void updateProductReviews(List<Product_Review__c> reviews) {
    // Check if the user has update permission on the Product_Review__c object
    if (Schema.sObjectType.Product_Review__c.isUpdateable()) {
        // Loop through each review to check field-level permissions
        for (Product_Review__c review : reviews) {
            // Check if the fields are updateable
            if (!Schema.sObjectType.Product_Review__c.fields.Review__c.isUpdateable() ||
                !Schema.sObjectType.Product_Review__c.fields.Overall_Sentiment_Type__c.isUpdateable() ||
                !Schema.sObjectType.Product_Review__c.fields.Overall_Sentiment_Score__c.isUpdateable()) {
                throw new AuraHandledException('Insufficient permissions to update one or more fields on Product_Review__c.');
            }
        }
        update reviews;
    } else {
        throw new AuraHandledException('Insufficient permissions to update Product_Review__c.');
    }
}

    
    @AuraEnabled
    public static Map<String, List<Product_Review__c>> getTopReviews(Id productId) {
        Map<String, List<Product_Review__c>> reviewsMap = new Map<String, List<Product_Review__c>>();
    
        // Query top 3 positive reviews
        List<Product_Review__c> positiveReviews = [
            SELECT Id, Review__c, Overall_Sentiment_Type__c, Overall_Sentiment_Score__c
            FROM Product_Review__c
            WHERE Product__c = :productId AND Overall_Sentiment_Type__c = 'positive'
            ORDER BY Overall_Sentiment_Score__c DESC
            LIMIT 3
        ];
        
        // Query top 3 negative reviews
        List<Product_Review__c> negativeReviews = [
            SELECT Id, Review__c, Overall_Sentiment_Type__c, Overall_Sentiment_Score__c
            FROM Product_Review__c
            WHERE Product__c = :productId AND Overall_Sentiment_Type__c = 'negative'
            ORDER BY Overall_Sentiment_Score__c DESC
            LIMIT 3
        ];
        
        reviewsMap.put('positiveReviews', positiveReviews);
        reviewsMap.put('negativeReviews', negativeReviews);
        
        return reviewsMap;
    }
    
}