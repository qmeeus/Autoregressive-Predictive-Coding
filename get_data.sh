#!/bin/bash -xe

DATA=./librispeech_data
KALDI=$DATA/kaldi
PREPROCESSED=$DATA/preprocessed

TRAIN100="https://www.dropbox.com/s/kl6ivulhucukdz1/train-clean-100.xz"
TRAIN500="https://www.dropbox.com/s/0hzg2momellrpoj/train-clean-360.xz"
TRAINOTH="https://www.dropbox.com/s/uy0aex30ufq2po8/train-other.xz"
DEVSET="https://www.dropbox.com/s/4f1ypyowwmkfapx/dev-clean.xz"

ROOT_DIRECTORY=$(pwd)
mkdir -p $KALDI
cd $KALDI

printf "Which training set to download? Available:
  [1] 100 hours (7.07 GB)
  [2] 300 hours (25.54 GB)
  [3] other (34.82 GB)
  Default: None "; read choice

case $choice in
  1) URL=$TRAIN100 ;;
  2) URL=$TRAIN500 ;;
  3) URL=$TRAINOTH ;;
  *) URL="";;
esac

if [ "$URL" ]; then
  echo "Downloading $URL"
  wget $URL
fi

printf "Download the development set? yN "; read yesno
case $yesno in
  Y|y) echo "Downloading $DEVSET" && wget $DEVSET ;;
  *) : ;;
esac

if [ "$(ls *.xz)" ]; then
  echo "Extracting the datasets"
  xz -d *.xz
fi

cd $ROOT_DIRECTORY
for subset in train dev; do
  SUBSET=$(ls $KALDI | tr " " "\n" | grep "^$subset-" | head -n1)
  if [ "$SUBSET" ]; then
    echo "Preparing $subset-set"
    python prepare_data.py --librispeech_from_kaldi $KALDI/$SUBSET --save_dir $PREPROCESSED/$SUBSET
  fi
done

