//
//  Feature.m
//  ECE256
//
//  Created by Troy Ferrell on 4/6/12.
//  Copyright (c) 2012 Troy Ferrell. All rights reserved.
//

#import "Observation.h"

#import "GryoData.h"

#import <math.h>

@implementation Observation

@synthesize featureGrouping;

- (id) initWithData:(NSMutableArray *) acceleromterData withGryo:(NSMutableArray *) gryoData
{
    if(self = [super init])
    {
        // do stuff
    }
    
    return self;
}

- (NSString *) processAcclerometer:(NSMutableArray *) acceleromterData
{
    double size = [acceleromterData count];
    double sum_X = 0, sum_Y = 0, sum_Z = 0;
    double min_X = 100, min_Y = 100, min_Z = 100;
    double max_X = -100, max_Y = -100, max_Z = -100;
   
    double oneNorm_X = 0, oneNorm_Y = 0, oneNorm_Z = 0;
    double infinityNorm = 0, fNorm = 0; 
    for(int i = 0; i < size; i++)
    {
        UIAcceleration *acceleration = [acceleromterData objectAtIndex:i];
        sum_X += acceleration.x;
        sum_Y += acceleration.y;
        sum_Z += acceleration.z;
        
        oneNorm_X += fabs(acceleration.x);
        oneNorm_Y += fabs(acceleration.y);
        oneNorm_Z += fabs(acceleration.z);
        
        double newInfinityNorm = fabs(acceleration.x + acceleration.y + acceleration.z);
        infinityNorm = MAX(newInfinityNorm, infinityNorm);
        
        fNorm += fabs( pow(acceleration.x, 2)) 
                       + fabs( pow(acceleration.y, 2))
                       + fabs( pow(acceleration.z, 2));
        
        NSLog(@"%f", acceleration.x);
        
        if(acceleration.x < min_X) min_X = acceleration.x;
        if(acceleration.y < min_Y) min_Y = acceleration.y;
        if(acceleration.z < min_Z) min_Z = acceleration.z;
        
        if(acceleration.z > max_Z) max_Z = acceleration.z;
        if(acceleration.x > max_X) max_X = acceleration.x;
        if(acceleration.y > max_Y) max_Y = acceleration.y;
    }
    
    double oneNorm = MAX(MAX(oneNorm_X, oneNorm_Y), oneNorm_Z);
    double forbeniusNorm = sqrt(fNorm);
    
    // TODO: L2 norm
    
    // calculate skewness
    // g = [1/n * sigma (Xi - mean)^3 ] / [[1/n *sigma (Xi - mean)^2]^3/2]
    
    // Calculate Kurtosis
    // g2 = [[1/n * sigma (Xi - mean)^4 ] / [[1/n sigma (Xi - mean)^2]^2]] - 3
    
    double skewnessSum_X = 0, skewnessSum_Y = 0, skewnessSum_Z = 0;
    double kurtosisSum_X = 0, kurtosisSum_Y = 0, kurtosisSum_Z = 0;
    double squaredSum_X_Bottom = 0, squaredSum_Y_Bottom = 0, squaredSum_Z_Bottom = 0;
    
    for (int i = 0; i < size; i++) 
    {
        UIAcceleration *acceleration = [acceleromterData objectAtIndex:i];
        skewnessSum_X += pow(acceleration.x - sum_X/size, 3);
        skewnessSum_Y += pow(acceleration.y - sum_Y/size, 3);
        skewnessSum_Z += pow(acceleration.z - sum_Z/size, 3);
        
        kurtosisSum_X += pow(acceleration.x - sum_X/size, 4);
        kurtosisSum_Y += pow(acceleration.y - sum_Y/size, 4);
        kurtosisSum_Z += pow(acceleration.z - sum_Z/size, 4);
        
        squaredSum_X_Bottom += pow(acceleration.x - sum_X/size, 2);
        squaredSum_Y_Bottom += pow(acceleration.y - sum_Y/size, 2);
        squaredSum_Z_Bottom += pow(acceleration.z - sum_Z/size, 2);
    }
    
    double skewness_X = ((1.0/size)*skewnessSum_X) / pow((1.0/size)*squaredSum_X_Bottom, 3.0/2.0);
    double skewness_Y = ((1.0/size)*skewnessSum_Y) / pow((1.0/size)*squaredSum_Y_Bottom, 3.0/2.0);
    double skewness_Z = ((1.0/size)*skewnessSum_Z) / pow((1.0/size)*squaredSum_Z_Bottom, 3.0/2.0);
    
    double kurtosis_X = ((1.0/size)*kurtosisSum_X) / pow((1.0/size)*squaredSum_X_Bottom, 2.0) - 3.0;
    double kurtosis_Y = ((1.0/size)*kurtosisSum_Y) / pow((1.0/size)*squaredSum_Y_Bottom, 2.0) - 3.0;
    double kurtosis_Z = ((1.0/size)*kurtosisSum_Z) / pow((1.0/size)*squaredSum_Z_Bottom, 2.0) - 3.0;
    
    NSString *str1 = [NSString stringWithFormat:@"%f, %f, %f", min_X, min_Y, min_Z];
    NSString *str2 = [NSString stringWithFormat:@"%f, %f, %f", max_X, max_Y, max_Z];
    NSString *str3 = [NSString stringWithFormat:@"%f, %f, %f", skewness_X, skewness_Y, skewness_Z];
    NSString *str4 = [NSString stringWithFormat:@"%f, %f, %f", kurtosis_X, kurtosis_Y, kurtosis_Z];
    NSString *str5 = [NSString stringWithFormat:@"%f, %f, %f", oneNorm, infinityNorm, forbeniusNorm];
    NSString *str6 = [NSString stringWithFormat:@"%f, %f, %f", sum_X/size, sum_Y/size, sum_Z/size];
    
    return [NSString stringWithFormat:@"%@, %@, %@, %@, %@, %@", str1, str2, str3, str4, str5, str6];
}

- (NSString *) processGryo:(NSMutableArray *) gryoData
{
    double size = [gryoData count];

    double sum_X = 0, sum_Y = 0, sum_Z = 0;
    double min_X = 100, min_Y = 100, min_Z = 100;
    double max_X = -100, max_Y = -100, max_Z = -100;
    double oneNorm_X = 0, oneNorm_Y = 0, oneNorm_Z = 0;
    double infinityNorm = 0, fNorm = 0; 
    for(int i = 0; i < size; i++)
    {
        GryoData *gryo = [gryoData objectAtIndex:i];
        sum_X += gryo.x;
        sum_Y += gryo.y;
        sum_Z += gryo.z;
        
        oneNorm_X += fabs(gryo.x);
        oneNorm_Y += fabs(gryo.y);
        oneNorm_Z += fabs(gryo.z);
        
        double newInfinityNorm = fabs(gryo.x + gryo.y + gryo.z);
        infinityNorm = MAX(newInfinityNorm, infinityNorm);
        
        fNorm += fabs( pow(gryo.x, 2)) 
                + fabs( pow(gryo.y, 2))
                + fabs( pow(gryo.z, 2));
        
        if(gryo.x < min_X) min_X = gryo.x;
        if(gryo.y < min_Y) min_Y = gryo.y;
        if(gryo.z < min_Z) min_Z = gryo.z;
        
        if(gryo.x > max_X) max_X = gryo.x;
        if(gryo.y > max_Y) max_Y = gryo.y;
        if(gryo.z > max_Z) max_Z = gryo.z;
    }
    
    double oneNorm = MAX(MAX(oneNorm_X, oneNorm_Y), oneNorm_Z);
    double forbeniusNorm = sqrt(fNorm);
    
    // calculate skewness
    // g = [1/n * sigma (Xi - mean)^3 ] / [[1/n *sigma (Xi - mean)^2]^3/2]
    
    // Calculate Kurtosis
    // g2 = [[1/n * sigma (Xi - mean)^4 ] / [[1/n sigma (Xi - mean)^2]^2]] - 3
    
    double skewnessSum_X = 0, skewnessSum_Y = 0, skewnessSum_Z = 0;
    double kurtosisSum_X = 0, kurtosisSum_Y = 0, kurtosisSum_Z = 0;
    double squaredSum_X_Bottom = 0, squaredSum_Y_Bottom = 0, squaredSum_Z_Bottom = 0;
    
    for (int i = 0; i < size; i++) 
    {
        GryoData *gryo = [gryoData objectAtIndex:i];
        skewnessSum_X += pow(gryo.x - sum_X/size, 3);
        skewnessSum_Y += pow(gryo.y - sum_Y/size, 3);
        skewnessSum_Z += pow(gryo.z - sum_Z/size, 3);
        
        kurtosisSum_X += pow(gryo.x - sum_X/size, 4);
        kurtosisSum_Y += pow(gryo.y - sum_Y/size, 4);
        kurtosisSum_Z += pow(gryo.z - sum_Z/size, 4);
        
        squaredSum_X_Bottom += pow(gryo.x - sum_X/size, 2);
        squaredSum_Y_Bottom += pow(gryo.y - sum_Y/size, 2);
        squaredSum_Z_Bottom += pow(gryo.z - sum_Z/size, 2);
    }
    
    double skewness_X = ((1.0/size)*skewnessSum_X) / pow((1.0/size)*squaredSum_X_Bottom, 3.0/2.0);
    double skewness_Y = ((1.0/size)*skewnessSum_Y) / pow((1.0/size)*squaredSum_Y_Bottom, 3.0/2.0);
    double skewness_Z = ((1.0/size)*skewnessSum_Z) / pow((1.0/size)*squaredSum_Z_Bottom, 3.0/2.0);
    
    double kurtosis_X = ((1.0/size)*kurtosisSum_X) / pow((1.0/size)*squaredSum_X_Bottom, 2.0) - 3.0;
    double kurtosis_Y = ((1.0/size)*kurtosisSum_Y) / pow((1.0/size)*squaredSum_Y_Bottom, 2.0) - 3.0;
    double kurtosis_Z = ((1.0/size)*kurtosisSum_Z) / pow((1.0/size)*squaredSum_Z_Bottom, 2.0) - 3.0;
    
    NSString *str1 = [NSString stringWithFormat:@"%f, %f, %f", min_X, min_Y, min_Z];
    NSString *str2 = [NSString stringWithFormat:@"%f, %f, %f", max_X, max_Y, max_Z];
    NSString *str3 = [NSString stringWithFormat:@"%f, %f, %f", skewness_X, skewness_Y, skewness_Z];
    NSString *str4 = [NSString stringWithFormat:@"%f, %f, %f", kurtosis_X, kurtosis_Y, kurtosis_Z];
    NSString *str5 = [NSString stringWithFormat:@"%f, %f, %f", oneNorm, infinityNorm, forbeniusNorm];
    NSString *str6 = [NSString stringWithFormat:@"%f, %f, %f", sum_X/size, sum_Y/size, sum_Z/size];
    return [NSString stringWithFormat:@"%@, %@, %@, %@, %@, %@", str1, str2, str3, str4, str5, str6];
}

- (NSString *) processMicFFT:(NSMutableArray *) micFFTData
{
    double size = [micFFTData count];
//    NSLog(@"%d", (int)size);
    double sum = 0, min = DBL_MAX, max = DBL_MIN;
    for(int i = 0; i < size; i++)
    {
        float point = [[micFFTData objectAtIndex:i] floatValue];
        sum += point;
        min = MIN(min, point);
        max = MAX(max, point);
    }
    
    return [NSString stringWithFormat:@"%f, %f, %f", sum/size, min, max];

}

- (NSString *) processMic:(NSMutableArray *) micData
{
    const double ALPHA = 0.05;
    double size = [micData count];
    
    double sum = 0, sum_low = 0;
    double min = 1000, min_low = 1000;
    double max = -1000, max_low = -1000;
    
    for(int i = 0; i < size; i++)
    {
        double point = [[micData objectAtIndex:i] doubleValue];
      
        double peakPowerForChannel = pow(10, (ALPHA * point));
        
        sum += peakPowerForChannel;
        min = MIN(min, peakPowerForChannel);
        max = MAX(max, peakPowerForChannel);
        
        double lowPassResult = ALPHA * point + (1.0 - ALPHA) * lowPassResult;
        
        sum_low += lowPassResult;
        min_low = MIN(min_low, lowPassResult);
        max_low = MAX(max_low, lowPassResult);
        
        //double lowPassResultsOffset = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * lowPassResultsOffset;	

    }
    
    NSString *str1 = [NSString stringWithFormat:@"%f, %f, %f", sum, min, max];
    NSString *str2 = [NSString stringWithFormat:@"%f, %f, %f", sum_low, min_low, max_low];
    
    return [NSString stringWithFormat:@"%@, %@", str1, str2];



}



- (NSString *) ToString
{
    return @"";
}

@end