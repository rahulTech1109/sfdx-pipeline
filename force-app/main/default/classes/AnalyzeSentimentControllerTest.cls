@isTest
private class AnalyzeSentimentControllerTest {

    @isTest
    static void testAnalyzeAndUpdateProduct() {
        // Setup test data
        Product2 product = new Product2(Name = 'Test Product');
        insert product;

        Product_Review__c review1 = new Product_Review__c(Product__c = product.Id, Overall_Sentiment_Type__c = 'positive', Overall_Sentiment_Score__c = 0.8);
        Product_Review__c review2 = new Product_Review__c(Product__c = product.Id, Overall_Sentiment_Type__c = 'neutral', Overall_Sentiment_Score__c = 0.5);
        Product_Review__c review3 = new Product_Review__c(Product__c = product.Id, Overall_Sentiment_Type__c = 'negative', Overall_Sentiment_Score__c = 0.2);
        insert new List<Product_Review__c>{review1, review2, review3};

        // Call the method
        Test.startTest();
        AnalyzeSentimentController.analyzeAndUpdateProduct(product.Id);
        Test.stopTest();

        // Verify results
        Product2 updatedProduct = [SELECT Aggregated_Positive_Sentiment__c, Aggregated_Neutral_Sentiment__c, Aggregated_Negative_Sentiment__c, Sentiment_Last_Analyzed_On__c FROM Product2 WHERE Id = :product.Id];
        System.assertEquals(1, updatedProduct.Aggregated_Positive_Sentiment__c, 'Positive sentiment count should be 1');
        System.assertEquals(1, updatedProduct.Aggregated_Neutral_Sentiment__c, 'Neutral sentiment count should be 1');
        System.assertEquals(1, updatedProduct.Aggregated_Negative_Sentiment__c, 'Negative sentiment count should be 1');
        System.assertNotEquals(null, updatedProduct.Sentiment_Last_Analyzed_On__c, 'Sentiment last analyzed date should be set');
    }

    @isTest
    static void testGetProductReviews() {
        // Setup test data
        Product2 product = new Product2(Name = 'Test Product');
        insert product;

        Product_Review__c review1 = new Product_Review__c(Product__c = product.Id, Review__c = 'Great product!', Overall_Sentiment_Type__c = 'positive', Overall_Sentiment_Score__c = 0.9);
        insert review1;

        // Call the method
        Test.startTest();
        List<Product_Review__c> reviews = AnalyzeSentimentController.getProductReviews(product.Id);
        Test.stopTest();

        // Verify results
        System.assertEquals(1, reviews.size(), 'There should be 1 review returned');
        System.assertEquals('Great product!', reviews[0].Review__c, 'The review text should match');
    }

    @isTest
    static void testUpdateProductReviews() {
        // Setup test data
        Product2 product = new Product2(Name = 'Test Product');
        insert product;

        Product_Review__c review1 = new Product_Review__c(Product__c = product.Id, Review__c = 'Great product!', Overall_Sentiment_Type__c = 'positive', Overall_Sentiment_Score__c = 0.9);
        insert review1;

        // Update the review
        review1.Review__c = 'Updated review!';
        List<Product_Review__c> reviewsToUpdate = new List<Product_Review__c>{review1};

        // Call the method
        Test.startTest();
        AnalyzeSentimentController.updateProductReviews(reviewsToUpdate);
        Test.stopTest();

        // Verify results
        Product_Review__c updatedReview = [SELECT Review__c FROM Product_Review__c WHERE Id = :review1.Id];
        System.assertEquals('Updated review!', updatedReview.Review__c, 'The review text should be updated');
    }

    @isTest
static void testGetTopReviews() {
    // Setup test data
    Product2 product = new Product2(Name = 'Test Product');
    insert product;

    Product_Review__c review1 = new Product_Review__c(Product__c = product.Id, Review__c = 'Amazing!', Overall_Sentiment_Type__c = 'positive', Overall_Sentiment_Score__c = 0.95);
    Product_Review__c review2 = new Product_Review__c(Product__c = product.Id, Review__c = 'Not bad.', Overall_Sentiment_Type__c = 'neutral', Overall_Sentiment_Score__c = 0.5);
    Product_Review__c review3 = new Product_Review__c(Product__c = product.Id, Review__c = 'Needs improvement.', Overall_Sentiment_Type__c = 'negative', Overall_Sentiment_Score__c = 0.2);
    Product_Review__c review4 = new Product_Review__c(Product__c = product.Id, Review__c = 'Fantastic!', Overall_Sentiment_Type__c = 'positive', Overall_Sentiment_Score__c = 0.9);
    Product_Review__c review5 = new Product_Review__c(Product__c = product.Id, Review__c = 'Terrible.', Overall_Sentiment_Type__c = 'negative', Overall_Sentiment_Score__c = 0.1);
    insert new List<Product_Review__c>{review1, review2, review3, review4, review5};

    // Call the method
    Test.startTest();
    Map<String, List<Product_Review__c>> reviewsMap = AnalyzeSentimentController.getTopReviews(product.Id);
    Test.stopTest();

    // Verify results
    List<Product_Review__c> positiveReviews = reviewsMap.get('positiveReviews');
    List<Product_Review__c> negativeReviews = reviewsMap.get('negativeReviews');

    // Verify positive reviews
    System.assertEquals(2, positiveReviews.size(), 'There should be 2 positive reviews returned');
    System.assert(positiveReviews[0].Overall_Sentiment_Score__c >= positiveReviews[1].Overall_Sentiment_Score__c, 'Positive reviews should be ordered by score in descending order');

    // Verify negative reviews
    System.assertEquals(2, negativeReviews.size(), 'There should be 2 negative reviews returned');
    System.assert(negativeReviews[0].Overall_Sentiment_Score__c >= negativeReviews[1].Overall_Sentiment_Score__c, 'Negative reviews should be ordered by score in descending order');
}

}