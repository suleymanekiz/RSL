#recommender system build upon pandas and python
#step 1 - import pandas
import pandas as pd 

#step 2 - import the movie revies data
full_movie_reviews = pd.read_csv("userreviews.csv", sep = ';')

#optional - glimpse on the full movie reviews dataframe
print(full_movie_reviews)

#step 3 - create a list of columns that contains in the data 
the_selected_movie = pd.DataFrame(columns=full_movie_reviews.columns.tolist())

#step 4 - select a movie of choice
the_selected_movie = full_movie_reviews[full_movie_reviews.movieName == 'birth-of-the-dragon']

#step 5 - have a glimpse on the code selected movie
print(the_selected_movie)

##Current evaluation##
#we noticed that we have 203514 rows of reviewers in 10 different columns
#Step 6 showed that we have 7 reviewers on our movie along with their score and names
#let us dig in deeper

#step 10 - No worries - read this when you are further in the script - here we create a dataframe for the absolute and relative scores for our movie of choice
entire_recommendations = pd.DataFrame(columns=full_movie_reviews.columns.tolist() + ['AbsoluteScoreIncrease', 'RelativeScoreIncrease'])
#step 7 - defining the reviewers (Authors) & their scores (Metascore_w) for the movie of selection (birth-of-the-dragon)
for idx, Author in the_selected_movie.iterrows(): #idx=index, iterrows=go through each row in the selected movie data
    user = Author[['Author']].iloc[0]
    score = Author [['Metascore_w']].iloc[0]

#now we want to find out on which movies the user (Author) has ranked another movie higher than our movie of selection
#this is also a step closer towards our recommendation system build upon python with pandas

#step 8 - create a funnel to select only the authors who ranked our movie along with its higher rate than our movie of selection
    other_recommendations = full_movie_reviews[(full_movie_reviews.Author==user) & (full_movie_reviews.Metascore_w>score)] 

#optional - print other_recommendations
#print(other_recommendations.head)#
#optional - the results shows that there are 222 reviews placed by the user (user or Authors) that have a higher score (score or Metascore_w) than our movie of selection (birth-of-the-dragon)

#step 9 - we are curious of what their relative along with its absolute increase would be when comparing the other 222 ratings with my movie of selection
    other_recommendations.loc[:,'AbsoluteScoreIncrease'] = other_recommendations.Metascore_w-score
    other_recommendations.loc[:,'RelativeScoreIncrease'] = other_recommendations.Metascore_w/score

#step 11 - we want to add these other_recommendations to our entire dataframe
    entire_recommendations = entire_recommendations.append(other_recommendations)

#step 12 - we want to remove any duplicate movies since multiple users can recommend the same movie. We want to have just 1 title instead of 20 of the same titles
entire_recommendations = entire_recommendations.drop_duplicates(subset = 'movieName', keep = 'first')

#step 13 - now we want to sort the recommendations of relative and absolute score increase by descending order
entire_recommendations = entire_recommendations.sort_values(['AbsoluteScoreIncrease', 'RelativeScoreIncrease'], ascending = False)

#step 14 print the recommendations
print(entire_recommendations)

#evaluation
#there are 1591 movies that are recommended to these 222 users isntead of our movie of selection (birth-of-the-dragon)

#save recommendation system to a csv file
entire_recommendations.to_csv('EntireRecommendations.csv', sep=';')
