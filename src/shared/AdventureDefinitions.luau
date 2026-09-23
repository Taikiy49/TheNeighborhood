-- Authored stories stay available permanently; no daily streaks or expiring rewards.
return {
 Landmarks={
  North={Name="The welcome post",Hint="At the north entrance, beside the community board.",Position=Vector3.new(-18,2,-113)},
  West={Name="The west-side letterbox",Hint="On the park side of the western sidewalk, halfway up Maple Street.",Position=Vector3.new(-45,2,-40)},
  East={Name="The east-side letterbox",Hint="Across the green, on the eastern sidewalk.",Position=Vector3.new(45,2,-40)},
  Market={Name="The market notice",Hint="Outside the shops, at the western end of the green.",Position=Vector3.new(-45,2,80)},
  Pawn={Name="The pawn-shop notice",Hint="Outside the shops, at the eastern end of the green.",Position=Vector3.new(45,2,80)},
  South={Name="The last bench",Hint="At the shop end of the park, beside the southern path.",Position=Vector3.new(18,2,110)},
 },
 Order={"Teaspoon","Bandit","Radio","Parade","Library","Moon"},
 Routes={
  Teaspoon={Title="The Great Teaspoon Heist",Stops={"North","Market","West"},Notes={"Ellis has reported a missing spoon. The shopkeeper knows more than she is letting on.","A receipt says: one spoon, one bag of soil, absolutely no questions. Check the west-side letterbox.","The spoon is a gnome-sized garden shovel. Case closed; soup postponed."}},
  Bandit={Title="The Biscuit Bandit",Stops={"East","South","North"},Notes={"A trail of crumbs points toward the last bench by the shops.","The witness describes four paws and an excellent poker face. A confession awaits at the welcome post.","Biscuit ate the evidence. His written apology is also mysteriously missing."}},
  Radio={Title="Midnight on Maple FM",Stops={"Market","East","Pawn"},Notes={"A mysterious radio station only plays doorbell sounds. Someone on the east sidewalk has a request.","The request is for a song called Please Stop Ringing My Doorbell. Try the pawn-shop notice.","The DJ is a microwave with a loose dial. Tonight's show has been cancelled for dinner."}},
  Parade={Title="The Invisible Parade",Stops={"Pawn","West","South"},Notes={"A parade permit lists zero musicians and one extremely confident flamingo. Check the west letterbox.","The marching band forgot to march. Their leader is waiting near the last bench.","The flamingo declares the parade a success. It has been standing here the entire time."}},
  Library={Title="The Book That Borrowed You",Stops={"West","Pawn","East"},Notes={"A library card names YOU as the book. Follow the overdue notice toward the pawn shop.","The pawn shop refuses to appraise a neighbor. Your new due date is posted on the east sidewalk.","The librarian has corrected the paperwork. You may keep your personality for another two weeks."}},
  Moon={Title="Operation Moon Cheese",Stops={"South","North","Market"},Notes={"A tiny rocket blueprint calls for cheese and three spoons. Check the welcome post.","Launch is delayed: the pilot is afraid of heights. The market notice has the final mission report.","The gnomes reached the top shelf. They call it the moon. Please don't ruin this for them."}},
 },
 Projects={
  {Title="Flowers for Maple Green",Goal=6,Description="Help the block grow a shared flower garden."},
  {Title="The Little Free Library",Goal=6,Description="Bring a book-sharing corner to the park."},
  {Title="An Evening Under Lanterns",Goal=6,Description="Light the garden with a row of warm lanterns."},
 },
 Rewards={
  {Id="TrailCompass",Title="Curiosity Compass",Kind="Trails",Target=1},
  {Id="StoryOwl",Title="Maple Story Owl",Kind="Trails",Target=6},
  {Id="NeighborLantern",Title="Good Neighbor Lantern",Kind="Contributions",Target=12},
 },
}
