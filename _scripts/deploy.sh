#!/bin/sh
jekyll build
rsync -e ssh -av --delete _site/* wandb@wallandbinkley.com:wallandbinkley.com/rcb/works/responsibledrinking/
