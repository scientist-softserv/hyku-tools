# Hyku::Tools

A collection of helpful tools when working on Hyku and Hyrax applications.

## Reviewing Repositories

Given the nature of Hyku installations, their reliance on Hyrax, and their relation to Hyku prime, it can be helpful to script the review of files.

The [`bin/left_v_right`](./bin/left_v_right) script reviews two directories, one on the *left* and one on the *right*.  The script writes to `STDOUT` with the information regarding the run; as well as an indicator of each of the files.

| Case for each file                   | Prefix |
|--------------------------------------|--------|
| in *left* but not in *right*         | `<`    |
| in *right* but not in *left*         | `>`    |
| in *left* and same as in *right*     | `=`    |
| in *left* but different from *right* | `Δ`    |

The files are filtered by the `patterns_to_check` parameter (see `bin/left_v_right -h` for details).  And the total set of files are the union of directory relative filenames in *left* and *right*.

```bash
./bin/left_v_right --left ~/git/palni-palci --right ~/git/hyku > to_review.txt
```

In the above script, the *left* directory (e.g. `~/git/palni-palci`) is a clone of <https://github.com/scientist-softserv/palni-palci.git>.  And the *right* `~/git/hyku` is a clone of <https://github.com/samvera/hyku.git>.  And I'm writing the output of the script to a `to_review.txt` file; for later review.

Before running the script, you'll need to manually ensure that each of those clones are in the correct state to begin the comparison (e.g. checked out the correct branches and I have a clean `git status` in both directories).

The output can then be used to establish a script on what to do for each case.  What do we do when we have a file in the left side but not the right side?  And so on.

### Example: Reviewing Hyku versus Hyrax

Hyku is a Rails application that mounts the Hyrax engine.  There are files in Hyku that override files in Hyrax; and there are files in both Hyku and Hyrax that are not in the other repository.  When working with Hyku, especially an upgrade, it can be useful to methodically review the files.

In this case, let's consider *left* to be Hyku and *right* to be Hyrax.  Reviewing each line of output there will be lines that start with one of the four characters: `<`, `>`, `=`, `Δ`.

- `<`: The file is in Hyku but not Hyrax.  Perhaps this is Hyku specific information (e.g. Tenant based considerations).  Or perhaps it was a file that once was in Hyrax but is no longer.
- `>`: The file is in Hyrax but not Hyku.  In our example, this is something that we can likely ignore.
- `=`: The file in Hyku and Hyrax is the same.  Odds are good that you could remove the file from Hyku, and instead rely on Hyrax.
- `Δ`: The file in Hyku differs from the one in Hyrax.  Why?

In working in Hyku and Hyrax, we have found that there are many files to consider.  And creating a checklist to methodically review those differences makes a lot of sense.

With the unique leading characters, we can write further automation to help us review the files.

The below script generates a file to review.  Then, from that file we search for files that are the same in Hyku as Hyrax (e.g. starts with `=`).  We then pipe those files to `xargs` which we then use to remove the file from Hyku:

```bash
./bin/left_v_right --left ~/git/hyku --right ~/git/hyrax > ~/to-review.txt

cat to-review.txt | 
  rg "^= (.*)" -r '$1' |
  xargs -n1 -I {} /bin/bash -c 'rm ~/git/hyku/{}'
```

For the `Δ` files, we probably want a different approach.  Similarly for the `<` files.  In the case of `>` files, we can almost certainly skip them.  After all something in Hyrax that is not in Hyku is an expectation of the Hyrax engine.

The [`bin/example-reviewer.rb`](./bin/example-reviewer.rb) script demonstrates a few concepts:

- Iterating through the `~/to-review.txt` file and handling each of the four file cases differently.
- Writing the decision notes to a `~/reviewed.txt` file.
- Allowing you to quit (via `CTRL-c`), save what you reviewed, and resume at where you left off.
