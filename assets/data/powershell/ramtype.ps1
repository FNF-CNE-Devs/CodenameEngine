		[string[]]$MEMORY_TYPES = @(
			'Invalid',  'Other',    'Unknown',  'DRAM',                 # 00-03h
			'EDRAM',    'VRAM',     'SRAM',     'RAM',                  # 04-07h
			'ROM',      'FLASH',    'EEPROM',   'FEPROM',               # 08-0Bh
			'EPROM',    'CDRAM',    '3DRAM',    'SDRAM',                # 0C-0Fh
			'SGRAM',    'RDRAM',    'DDR',      'DDR2',                 # 10-13h
			'DDR2 FB-DIMM', 'Reserved', 'Reserved', 'Reserved',         # 14-17h
			'DDR3',     'FBD2',     'DDR4',     'LPDDR',                # 18-1Bh
			'LPDDR2',   'LPDDR3',   'LPDDR4',   'Logical non-volatile device' # 1C-1Fh
			'HBM (High Bandwidth Memory)', 'HBM2 (High Bandwidth Memory Generation 2)',
				'DDR5', 'LPDDR5'                                        # 20-23h
		)
		
		function lookUp([string[]]$table, [int]$value){$table[$value]}
		
		function parseTable([array]$table, [int]$begin, [int]$end)
		{
			[int]$index = $begin
			$type = $table[$index + 0x12]
			$(lookUp $MEMORY_TYPES $type)
		}
		$index = 0
		
		$END_OF_TABLES = 127
		$MEMORY_DEVICE = 17
		$BiosTables = (Get-WmiObject -ComputerName . -Namespace root\wmi -Query `
			'SELECT SMBiosData FROM MSSmBios_RawSMBiosTables' `
		).SMBiosData
		
		do
		{
			$startIndex = $index
			$tableType = $BiosTables[$index]
			if ($tableType -eq $END_OF_TABLES) { break }
			$tableLength = $BiosTables[$index + 1]
			$index += $tableLength
			while ([BitConverter]::ToUInt16($BiosTables, $index) -ne 0) { $index++ }
			$index += 2
			if ($BiosTables[$index] -eq 0) { $index++ }
			if ($tableType -eq $MEMORY_DEVICE) { parseTable $BiosTables $startIndex $index }
		} until ($tableType -eq $END_OF_TABLES -or $index -ge $BiosTables.length)