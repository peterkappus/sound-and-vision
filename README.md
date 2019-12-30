# Sound and Vision

Experiments with Super Collider and HTML (P5) to create cool sounds and things to look at.

## Hardware Requirements
1. A laptop (e.g. MacBook Pro)
2. A midi controller (I'm using an M-Audio Oxygen25) 
3. USB connection between them.

## Software Requirements
1. [Super Collider](https://supercollider.github.io/)
2. Chrome (for visualisation)
3. Optional: [Touch OSC](https://hexler.net/products/touchosc) on iOS


## Audio Setup
These steps allow you to play through GarageBand to avoid breaking your ears or your gear. This also allows you to record your creations.

1. Install the [BlackHole](https://github.com/ExistentialAudio/BlackHole) audio driver
2. Open Garage Band 
3. Create a new audio track using BlackHole as the input.
4. Turn on monitoring.
5. In your SC sketch, set the audio device to the Blackhole driver, something like this: ` Server.default.options.device = "BlackHole 16ch";`
To see available drivers, use `ServerOptions.devices;`

You should now hear SC audio through GarageBand. This means you can record it. You can also use this input for recording screencasts (with QuickTime Player) or using other recording software. 

## Running the live video
1. Open "index.html"
2. Play some midi notes
3. See the "snow" fall with each note.
4. Bonus: Fullscreen the browser and move the mouse to the side

## Development Workflow
This workflow should work for any project, the below explains how to create a new feature branch, autosave every 2 min and then merge/squash the commits into a single commit on the master branch.
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
```
