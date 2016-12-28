#Extract tags by name
# Input: [{Key: key1, Value: val1}, ...]
# key: key to select
# Output: Value of selected key
def tag(key): select(.Key==key).Value;

#Flatten output of "ec2 describe-instances" to a list of only instances (no reservations)
def allinst: .Reservations[].Instances[];

#Check if a value contains any from a list of values
# Input: a string or list
# subs: a list of sub-items (strings if input is a string, lists if input is a list)
# Output: true if any of the items in "subs" are contained in the input
def anyin(subs): . as $val | subs | any(inside($val));
