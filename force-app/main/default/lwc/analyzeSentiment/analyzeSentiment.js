import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import analyzeAndUpdateProduct from '@salesforce/apex/AnalyzeSentimentController.analyzeAndUpdateProduct';
import getProductReviews from '@salesforce/apex/AnalyzeSentimentController.getProductReviews';
import updateProductReviews from '@salesforce/apex/AnalyzeSentimentController.updateProductReviews';
import transjs from '@salesforce/resourceUrl/transformersForLwc';
import { loadScript } from 'lightning/platformResourceLoader';
import loadingGif from '@salesforce/resourceUrl/sentimentLoadingGif';
import sentimeterIcon from '@salesforce/resourceUrl/sentimeterIcon';
import getTopReviews from '@salesforce/apex/AnalyzeSentimentController.getTopReviews';


const PRODUCT_FIELDS = [
    'Product2.Aggregated_Positive_Sentiment__c',
    'Product2.Aggregated_Neutral_Sentiment__c',
    'Product2.Aggregated_Negative_Sentiment__c',
    'Product2.Sentiment_Last_Analyzed_On__c'
];

const PRODUCT_REVIEW_FIELDS = [
    'Product_Review__c.Overall_Sentiment_Type__c'
];

export default class AnalyzeSentiment extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track productData;
    wiredProductResult;
    isLoading = false;
    buttonVariant = 'brand-outline';
    @track statusMessage = '';
    @track progressLabel = 'Initializing...';
    @track progressPercentage = 0;
    @track progressBarWidth = '0%';
    @track progressBarStyle = 'width:0%;';

    // Variables for Sentiment model
    transjsInitialized = false;
    sentimentPipeline = null;
    @track sentimentResult;
    @track iteration = 0;
    @track modelProgress = 0;

    @track isConnected = false; // Track connection state
    @track isRecordLoaded = false; // Track if the record data is loaded
    @track isPipelineInitialized = false;

    @track topPositiveReviews = [];
    @track topNegativeReviews = [];

    connectedCallback() {
        this.isConnected = true;
        this.isProductRecord = this.objectApiName === 'Product2';
        //console.log("Inside Connected Callback" + this.isProductRecord);
        this.fetchTopReviews();
    }

    // Conditionally fetch product or product review data based on the object type
    @wire(getRecord, {
        recordId: '$recordId',
        fields: '$fields'
    })
    wiredRecord(value) {
        if (this.isConnected) { // Ensure connectedCallback has executed
            this.wiredResult = value;
            if (value.data) {
                if (this.isProductRecord) {
                    this.productData = value;
                } else {
                    this.productReviewData = value;
                }
                this.isRecordLoaded = true; // Set the flag when data is loaded
            } else if (value.error) {
                this.isRecordLoaded = false; // Handle error case
            }
        }
    }

    // Getter to determine which fields to fetch
    get fields() {
        //console.log("Inside fields");
        return this.isProductRecord ? PRODUCT_FIELDS : PRODUCT_REVIEW_FIELDS;
    }

    get loadingGifUrl() {
        return loadingGif;
    }

    get sentimeterIconUrl() {
        return sentimeterIcon;
    }

    get sentimentScoresAvailable() {
        const fields = this.productData?.data?.fields;
        return fields?.Aggregated_Positive_Sentiment__c?.value != null ||
            fields?.Aggregated_Neutral_Sentiment__c?.value != null ||
            fields?.Aggregated_Negative_Sentiment__c?.value != null;
    }

    get positiveSentimentScore() {
        return this.productData?.data ? this.productData.data.fields.Aggregated_Positive_Sentiment__c.value : 'N/A';
    }

    get neutralSentimentScore() {
        return this.productData?.data ? this.productData.data.fields.Aggregated_Neutral_Sentiment__c.value : 'N/A';
    }

    get negativeSentimentScore() {
        return this.productData?.data ? this.productData.data.fields.Aggregated_Negative_Sentiment__c.value : 'N/A';
    }

    get lastAnalyzedOn() {
        return this.productData?.data ? this.productData.data.fields.Sentiment_Last_Analyzed_On__c.value : 'N/A';
    }

    get IsProductReviewPositive() {
        return this.isRecordLoaded && this.productReviewData.data.fields.Overall_Sentiment_Type__c.value === 'positive';
    }

    get IsProductReviewNeutral() {
        return this.isRecordLoaded && this.productReviewData.data.fields.Overall_Sentiment_Type__c.value === 'neutral';
    }

    get IsProductReviewNegative() {
        return this.isRecordLoaded && this.productReviewData.data.fields.Overall_Sentiment_Type__c.value === 'negative';
    }

    get isSentimentAvailableForProductReview() {
        const fields = this.productReviewData?.data?.fields;
        return fields?.Overall_Sentiment_Type__c?.value != null;
    }

    handleButtonClick() {
        this.isLoading = true;
        this.buttonVariant = 'brand-outline';
        this.updateProgressBar('Initializing...', 5);

        getProductReviews({ productId: this.recordId })
            .then(reviews => {
                this.updateProgressBar('Fetched Product Reviews...', 20);
                this.noOfReviews = reviews.length;
                this.intervalCounter = Math.round(this.noOfReviews / 60);

                const reviewPromises = reviews.map((review, index) => {
                    return new Promise((resolve) => {
                        setTimeout(() => {
                            const reviewCopy = JSON.parse(JSON.stringify(review));
                            if (review.Review__c) {
                                //console.log("text is null for index:"+index)
                                this.getSentiment(review.Review__c.replace(/[^a-zA-Z0-9 ]/g, '').replace(/\n/g, ' ').substring(0, 2000))
                                    .then(sentiment => {
                                        // console.log("Review is: " + review.Review__c + "Sentiment is: " + sentiment.label + "Score is: " + sentiment.score);
                                        if (sentiment.label === 'positive') {
                                            reviewCopy.Overall_Sentiment_Type__c = 'positive';
                                            reviewCopy.Overall_Sentiment_Score__c = sentiment.score;
                                        } else if (sentiment.label === 'neutral') {
                                            reviewCopy.Overall_Sentiment_Type__c = 'neutral';
                                            reviewCopy.Overall_Sentiment_Score__c = sentiment.score;
                                        } else if (sentiment.label === 'negative') {
                                            reviewCopy.Overall_Sentiment_Type__c = 'negative';
                                            reviewCopy.Overall_Sentiment_Score__c = sentiment.score;
                                        }
                                        //console.log(index)
                                        if (index % this.intervalCounter === 0)
                                            this.updateProgressBar('Analyzing Sentiment...', 20 + (index / this.intervalCounter));
                                        resolve(reviewCopy);
                                    })
                                    .catch(error => {
                                        console.error('Error while updating sentiment:', error);
                                        resolve(reviewCopy); // resolve with original review in case of error
                                    });
                            } else {
                                // Skip getSentiment if review.Review__c is null or empty
                                resolve(reviewCopy);
                            }
                        }, 10); // 10ms delay for each review
                    });
                });

                return Promise.all(reviewPromises);
            })
            .then(updatedReviews => {
                return updateProductReviews({ reviews: updatedReviews });
            })
            .then(() => {
                this.updateProgressBar('Updating Reviews with Sentiment...', 85);
                return analyzeAndUpdateProduct({ productId: this.recordId });
            })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Sentiment Analysis is successful',
                        variant: 'success'
                    })
                );
                this.updateProgressBar('Finalizing Sentiment for Product...', 90);
                this.updateProgressBar('Finalizing Sentiment for Product...', 100);
                return refreshApex(this.wiredResult);
            })
            .then(() => {
                this.fetchTopReviews();  // Fetch top reviews after updating product
            })
            .catch(error => {
                let errorMessage = 'An unknown error occurred';
                if (error.body && error.body.message) {
                    errorMessage = error.body.message;
                } else if (Array.isArray(error.body) && error.body[0] && error.body[0].message) {
                    errorMessage = error.body[0].message;
                }
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while performing Sentiment Analysis',
                        message: errorMessage,
                        variant: 'error'
                    })
                );
                console.error('Error:', error);
            })
            .finally(() => {
                this.statusMessage = '';
                this.isLoading = false;
                this.buttonVariant = 'brand-outline';
                this.progressPercentage = 100;
                this.progressBarWidth = '100%';
            });
    }

    getSentiment(text) {
        if (!this.sentimentPipeline) {
            //console.error('Sentiment pipeline is not initialized');
            return Promise.reject('Sentiment pipeline is not initialized');
        }
        // console.log("before Text is: " + text)
        return this.sentimentPipeline(text)
            .then(result => {
                //console.log("Text is: " + text + "Label is: " + result[0].label + "Score is: " + result[0].score);
                return { label: result[0].label, score: result[0].score };
            })
            .catch(error => {
                console.error('Error in sentiment analysis:', error);
                throw error;
            });
    }

    renderedCallback() {
        if (this.transjsInitialized) {
            return;
        }
        this.transjsInitialized = true;

        loadScript(this, transjs)
            .then(() => {
                console.log('Script loaded');
                this.cyclicProgressBar();
                return this.initializePipeline();
            })
            .catch(error => {
                this.error = error;
                console.log('Error in renderedCallback:', error);
            });
    }

    initializePipeline() {
        if (this.sentimentPipeline) {
            return Promise.resolve();
        }

        return window.pipeline('text-classification', 'Xenova/twitter-roberta-base-sentiment-latest')
            .then(pipeline => {
                this.sentimentPipeline = pipeline;
                this.isPipelineInitialized = true;
                //console.log('Sentiment pipeline initialized');
                clearInterval(this.progressInterval);
            })
            .catch(error => {
                console.error('Error initializing sentiment pipeline:', error);
                throw error;
            });
    }

    cyclicProgressBar() {
        let progress = 0;
        this.progressInterval = setInterval(() => {
            progress = progress + 10;
            this.modelProgress = progress;
            if (progress >= 100) {
                progress = 0;
            }
        }, 50); // Adjust the interval time as needed (e.g., 100ms)
    }

    updateProgressBar(message, percentage) {
        this.progressLabel = message;
        this.progressPercentage = percentage;
        this.progressBarWidth = `${percentage}%`;
        this.progressBarStyle = `width:${percentage}%`;
    }

    fetchTopReviews() {
        getTopReviews({ productId: this.recordId })
            .then(reviewsMap => {
                this.topPositiveReviews = this.truncateReviews(reviewsMap.positiveReviews);
                this.topNegativeReviews = this.truncateReviews(reviewsMap.negativeReviews);
            })
            .catch(error => {
                console.error('Error fetching top reviews:', error);
            });
    }

    truncateReviews(reviews) {
        const maxLength = 100;
        return reviews.map(review => ({
            ...review,
            Review__c: review.Review__c.length > maxLength
                ? review.Review__c.substring(0, maxLength) + '...'
                : review.Review__c
        }));
    }
    
}