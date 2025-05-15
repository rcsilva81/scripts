# ExportDBMySQL.sh

This script is designed to export data, tables, views, and routines from a MySQL database, making it easier to migrate or back up databases between servers.

## Features
- Exports MySQL routines (functions and procedures)
- Exports tables and views structure
- Exports data (with option to ignore specific tables)
- Removes DEFINER statements for portability
- Disables foreign key checks for easier import
- Logs errors and execution times for each step

## Usage
1. **Edit the script variables** at the top of the file to match your environment:
   - `vUser`, `vPass`, `vNewHost`, `vPort`, `vBD2Export`, `vExportDir`, etc.
2. **Ensure you have the necessary permissions** to run mysqldump and write to the export directory.
3. **Run the script:**
   ```bash
   bash ExportDBMySQL.sh
   ```
4. The exported SQL files will be saved in the directory specified by `vExportDir`.

## Notes
- The script logs errors to files like `error_routines.log`, `error_tables.log`, and `error_data.log`.
- The script uses `sed` to remove DEFINER statements and to disable foreign key checks in the exported files.
- Review and adapt the script as needed for your specific use case and environment.

## Warning
**Do not share your script with hardcoded passwords or sensitive information.**

---

Feel free to contribute improvements or report issues!
