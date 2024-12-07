import json
import xml.etree.ElementTree as ET
from xml.dom import minidom
import argparse
import os

def json_to_xml(json_data):
	root = ET.Element('character', {
		'y': str(json_data['position'][1]),
		'sprite': json_data['healthicon'],
		'flipx': str(json_data['flip_x']).lower(),
		'isPlayer': 'true',
		'icon': json_data['healthicon'],
		'color': f"#{''.join(f'{c:02X}' for c in json_data['healthbar_colors'])}"
	})

	for anim in json_data['animations']:
		anim_element = ET.SubElement(root, 'anim', {
			'name': anim['anim'],
			'anim': anim['name'],
			'x': str(anim['offsets'][0]),
			'y': str(anim['offsets'][1]),
			'fps': str(anim['fps']),
			'loop': str(anim['loop']).lower()
		})

	unpretty = ET.tostring(root, encoding='unicode', method='xml')
	pretty = minidom.parseString(unpretty)
	old_xml = pretty.toprettyxml(indent="	")
	nu_xml = old_xml.replace(
		'<?xml version="1.0" ?>',
		'<!DOCTYPE codename-engine-character>'
	)

	return nu_xml

def main():
	parser = argparse.ArgumentParser(description="Convert Psych/Misc JSON Characters to XML for Codename Engine")
	parser.add_argument('input_file', type=str, help="Full file Path to the JSON file.")
	parser.add_argument('output_folder', type=str, help="Path to Codename Engine characters folder.")

	args = parser.parse_args()
	input_file = args.input_file
	output_folder = args.output_folder

	# make sure that our shit exists
	if not os.path.isfile(input_file):
		print("json not found")
		return

	if not os.path.isdir(output_folder):
		print("codename character folder not found")
		return

	# ok it exists we ballin
	# time to lock in
	with open(input_file, 'r') as file:
		json_data = json.load(file)

	xml_data = json_to_xml(json_data)

	input_filename = os.path.basename(input_file)
	output_filename = os.path.basename(input_file).split(".")[0] + '.xml'
	output_file = os.path.join(output_folder, output_filename)

	with open(output_file, 'w') as file:
		file.write(xml_data)

	print("file has been converted check the codename characters folder")

if __name__ == "__main__":
	main()