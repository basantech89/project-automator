#!/usr/bin/env bash

# Set/Reset
RESET='0'
BOLD='1'
DIM='2'
UNDERLINE='4'
BLINK='5'
HIGHLIGHT='7'
HIDDEN='8'

# MODE
FG='\033[38'
BG='\033[48;2'

# COLORS
NC='\033[0m' #NoColor
WHITE='255;255;255'
BLACK='0;0;0'
GREEN='0;160;0'
ALICE='16;120;150'
RUBY='192;47;29'
CORAL='242;109;33'
WEED='35;43;43'
HONEY='227;147;87'
ROSE='223;103;140'
DENIM='61;21;95'
JUNGLE='139;216;189'
SPACE='36;54;101'
SCARLET='236;139;94'
SHADOW='20;26;70'
SAPHIRE='41;40;38'
HUNTER='249;211;66'
PUNCH='239;84;85'
PERSIAN='43;50;82'

# HEADERS
TITLE="${BG};${JUNGLE}m${FG};${DIM};${SPACE}m"
SUBTITLE="${BG};${DENIM}m${FG};${DIM};${WHITE}m"
PACKAGE="${BG};${ROSE}m${FG};${DIM};${DENIM}m"
PPA="${BG};${CORAL}m${FG};${BOLD};${WHITE}m"
UPDATE="${BG};${PUNCH}m${FG};${DIM};${PERSIAN}m"
WARN="${BG};${HUNTER}m${FG};${DIM};${SAPHIRE}m"
ERROR="${BG};${RUBY}m${FG};${BOLD};${WHITE}m"
INFO="${FG};${DIM};${JUNGLE}m"
SUCCESS="${BG};${GREEN}m${FG};${DIM};${WHITE}m"
PROMPT="${BG};${ALICE}m${FG};${BOLD};${WHITE}m"
FONT="${BG};${PUNCH}m${FG};${DIM};${WHITE}m"

# log "${TITLE}" "------------------- TITLE: ${@} -------------------"
# log "${SUBTITLE}" "------------------- SUBTITLE: ${@} -------------------"
# log "${WARN}" "------------------- WARN: ${@} -------------------"
# log "${PACKAGE}" "------------------- PACKAGE: ${@} -------------------"
# log "${PPA}" "------------------- PPA: ${@} -------------------"
# log "${UPDATE}" "------------------- UPDATE: ${@} -------------------"
# log "${ERROR}" "------------------- ERROR: ${@} -------------------"
# log "${INFO}" "------------------- INFO: ${@} -------------------"
# log "${SUCCESS}" "------------------- SUCCESS: ${@} -------------------"
# log "${PROMPT}" "------------------- PROMPT: ${@} -------------------"
# log "${FONT}" "------------------- PROMPT: ${@} -------------------"
# log "${NC}" "------------------- NC: ${@} -------------------"
