(: You can activate the content completion by pressing the Ctrl+Space keys. :)
xquery version "1.0";

(: Namespace for the <oXygen/> custom functions and variables :)
declare namespace oxy="http://www.oxygenxml.com/xquery/functions";

(: The movies XML document :)
declare variable $oxy:movies as document-node() := doc("movies.xml");

(: The reviews XML document :)
declare variable $oxy:reviews as document-node() := doc("reviews.xml");

declare function oxy:movie-ratings($movies-doc as document-node(), $reviews-doc as document-node()) {

    for $movie in $movies-doc/movies/movie
    let $movie-id := $movie/@id
    let $avgRating := avg($reviews-doc/reviews/review[@movie-id = $movie-id]/rating)
    let $maxRating := max($reviews-doc/reviews/review[@movie-id = $movie-id]/rating)
    let $minRating := min($reviews-doc/reviews/review[@movie-id = $movie-id]/rating)
    return
     <movie id="{$movie/@id}">
      {$movie/title}
      {$movie/year}
     <avgRating>
          {  
             if ($avgRating) then $avgRating else "not rated"
          }
     </avgRating>
      <maxRating>
          <value>
            {
                if ($maxRating) then $maxRating else "not rated"
            }
          </value>
          {
              for $rev in $reviews-doc/reviews/review
              where ((compare($rev/rating/text(), string($maxRating)) eq 0) 
                      and ($rev/@movie-id = $movie/@id))
              return $rev/author
          }
      </maxRating>
      <minRating>
          <value>
            {
                if ($minRating) then $minRating else "not rated"
            }
          </value>
          {
              for $rev in $reviews-doc/reviews/review
              where ((compare($rev/rating/text(), string($minRating)) eq 0) 
                      and ($rev/@movie-id = $movie/@id))
              return $rev/author
          }
      </minRating>
     </movie>
};

oxy:movie-ratings($oxy:movies, $oxy:reviews)
