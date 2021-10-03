Feature: User can manually edit movie


Scenario: Edit movie
  Given I am on the RottenPotatoes home page
  When I follow "Add New movie"
  Then I should be on the Create New Movie page
  When I fill in "Title" with "Men In Black"
  And I select "PG-13" from "Rating"
  And I press "Create Movie"
  Then I should be on the RottenPotatoes home page
  And I should see "Men In Black"
  Then I follow "More about Men In Black"
  Then I follow "Edit"
  And I should be on the Edit Existing Movie page
  When I fill in "Description" with "Men"
  And I press "Update Movie Info"
  And I should see "Men In Black"