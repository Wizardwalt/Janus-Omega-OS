-- board_flasher.lua
function execute(target_board, firmware_image)
    overseer_speak("Board Flasher engaged.")
    flash_firmware(target_board, firmware_image)
end
