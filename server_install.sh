#! /bin/bash


if test -z $1; then
    echo "Please supply host"; exit 0;
else
    HOST="$1"
fi

echo "Installing SSH"
# first we sort out ssh and sshkeys so we don't need to give our pword for every single scp
sudo apt-get install openssh-server openssh-client
ssh-keygen -t rsa
cat .ssh/id_rsa.pub | ssh $HOST 'cat >> .ssh/authorized_keys'


echo "Installing Standard Development and NAS Packages"
# Copy the package_list.txt over, install all of them
scp $HOST:package_list.txt .
sudo apt-get install $(grep -vE "^\s*#" package_list.txt  | tr "\n" " ")


echo "Installing Standard Configs"
# Copy over all standard configs
scp -r $HOST:bin .
scp -r $HOST:.bash_aliases .
scp -r $HOST:.bashrc .
scp -r $HOST:.config .
scp -r $HOST:.ctags .
scp -r $HOST:.git* .
scp -r $HOST:.gdb* .
scp -r $HOST:.jedi .
scp -r $HOST:.tmux.conf .
scp -r $HOST:.todo .
scp -r $HOST:.welcome_message .
scp -r $HOST:.ycm* .

echo "Installing VIM Configs"
# Copy over vim stuff, leave the bundles directory alone and manually do BundleInstall and compile things like YouCompleteMe by hand
mkdir -p .vim/bundle
scp -r $HOST:.vimrc .
scp -r $HOST:.vim/colors .vim/
scp -r $HOST:.vim/doc .vim/
scp -r $HOST:.vim/indent .vim/
scp -r $HOST:.vim/plugin .vim/
scp -r $HOST:.vim/snippets .vim/
scp -r $HOST:.vim/syntax.vim/
scp -r $HOST:.vim/tags .vim/
scp -r $HOST:.vim/templates .vim/
git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle

# code
echo "Copying python code workspace"
mkdir code
scp -r $HOST:code/python code/

# copy the msql db

