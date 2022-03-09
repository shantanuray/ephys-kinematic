# Process anipose+ephys data
## Batch Script (Main):
* Ask user for root dir, savedir
* Call function: List of folders with anipose data for root dir
* Output array with parent anipose dirs of pose-3d folder
* For each parent anipose dir
** If Save dir empty, Save dir = ?
** Save label = anipose+ephys.label
** Call function: Get anipose+ephys dir info from parent anipose folder (single)
*** Output - anipose+ephys
** Load anipose data using anipose+ephys.aniposedir
*** Output aniposeData
** Load ephys data using anipose+ephys.ephysdir
*** Output [EMG, solenoid, ...]
** Call Trial segmentation using [aniposeData, EMG, solenoid, spout, ...]
*** Output Trail list
*** Save Trail list to Save Dir\Save Label

# Process directory structure

## function: List of folders with anipose data 
* Take input as the main root folder
* List all pose-3d (indication that annipose data exists)
* Output array with parent anipose dirs of pose-3d folder

## Additional function
* Write parent anipose dirs to file - temp
* function: Supplementary function to get video dirs list from file

## function: Get anipose+ephys dir info from parent anipose folder (single)
* Init anipose+ephys dir info struct
	anipose+ephys
		- label
		- aniposedir
		- ephysdir
* For individual anipose dir:
** Find parent ephys dir from anipose dir name
** Save parent ephys dir name as anipose+ephys.label
** Save parent anipose dir name as anipose+ephys.aniposedir
** List all oebin in parent ephys dir
** Extract parent dir of oebin and choose largest
** Save chosen parent dir of oebin as anipose+ephys.ephysdir

