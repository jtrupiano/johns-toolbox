/^Author:/ {
   author           = $2
   commits[author] += 1
   commits["tot"]  += 1
}

/^[0-9]+ +[0-9]+ +vendor|framework/ { next }

/^[0-9]/ {
   more[author] += $1
   less[author] += $2
   file[author] += 1

   more["tot"]  += $1
   less["tot"]  += $2
   file["tot"]  += 1
}

END {
   for (author in commits) {
      if (author != "tot") {
         avgmore[author]    = more[author] / more["tot"] * 100
         avgless[author]    = less[author] / less["tot"] * 100
         avgfile[author]    = file[author] / file["tot"] * 100
         avgcommits[author] = commits[author] / commits["tot"] * 100

         printf "%s:\n  insertions: %8d (%2.0f%%)\n  deletions:  %8d (%2.0f%%)\n  files:      %8d (%2.0f%%)\n  commits:    %8d (%2.0f%%)\n", author, more[author], avgmore[author], less[author], avgless[author], file[author], avgfile[author], commits[author], avgcommits[author]
      }
   }
}
