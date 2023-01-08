# Sound and Vision

Sonic and visual experiments using [SuperCollider](https://supercollider.github.io/) and [p5.js](https://p5js.org/) to make audio/visual artworks. Some are stand alone pieces that run on their own in a browser (see musical dots), others are instruments, audio processors, or other tools which can be used (often with audio or Midi input) to create different things.

Check individual folders for specific projects & their respective READMEs.

## What's in here?
* `supercollider` - SuperCollider instruments, experiments, etc. (Quite messy right now.)
* `web` - Things which run in a web browser
* `utils` - Utilities for stitching together video and audio files, resizing videos for instagram, etc.

## Caveat Emptor!
Buyer beware ;-) Sometimes I pretend to be a "real engineer" but working on this repo is not one of those times ;-) Expect really sloppy code, poor style, little to no documentation, things that break and move and change without warning, zero tests, etc. One day I'll clean up my act but for today, this is really just a fun sandbox to play with and make stuff that I like ;-) 

## License
What license? I'm a bit clueless about licenses so how about this: use this code for inspiration, if you find it useful and make something cool, please give me credit wherever possible. kthanxbai.


## Software Requirements
1. [Super Collider](https://supercollider.github.io/)
2. Chrome Browser (for visualisation)
3. Optional: [Touch OSC](https://hexler.net/products/touchosc) on iOS
4. Optional: Docker for `ffmpeg` and other utils

## Audio Tips for SuperCollider
These steps allow you to play through GarageBand to avoid breaking your ears or your gear when playing with SuperCollider. This also allows you to record your creations.

1. Install the [BlackHole](https://github.com/ExistentialAudio/BlackHole) audio driver
2. Open Garage Band 
3. Create a new audio track using BlackHole as the input.
4. Turn on monitoring.
5. In your SC sketch, set the audio device to the Blackhole driver, something like this: ` Server.default.options.device = "BlackHole 16ch";`
To see available drivers, use `ServerOptions.devices;`

You should now hear SC audio through GarageBand. This means you can record it. You can also use this input for recording screencasts (with QuickTime Player) or using other recording software. 


## Video capture & formatting tips (e.g. for Instagram)
1. Need sound? 
2. Install the [BlackHole](https://github.com/ExistentialAudio/BlackHole) audio driver and restart your mac
3. Select "blackhole 2 ch" as the audio output (from the menu bar icon)
2. Open Quicktime Player
2. Select "New Screen Recording"
2. Select "Blackhole 2ch" as audio source
2. Choose an area of the screen to capture
2. Play your video...
2. Trim it in quicktime and save it


## Preparing a video for Instagram:

1. save video in "captures" folder
2. in terminal: "./utilities/prep_for_insta.sh <INPUT_FILE_PATH> <FADE_START_TIME> <FADE_DURATION>
3. TIP: Use a start time longer than the duration of your clip if you don't want a fade...
4. Open "iCloud Drive" on your phone
5. View the video file
6. Save it to your camera roll
7. Open Instagram and add to your stories, or create a new post
8. Find the video in your camera roll

## Local Development

### Workflow
This workflow should work for any project, the below explains how to create a new feature branch, autosave every 2 min and then merge/squash the commits into a single commit on the master branch.

Of course, with multiple people doing "real" development together, you should probably use Pull Requests.

```
#create a new 'working' branch for experimentation
git checkout -b working

#auto-commit to this new branch every 2min
watch -n 120 git commit -am autosave

#ready to merge & commit to master?

#switch back to master
git checkout master

#squash all commits from the "working" branch into changes on this one
git merge --squash working

#commit these changes with a meaningful commit comment
git commit -am "My useful comment about this new feature"

# delete the old working branch
git branch -d working
```
