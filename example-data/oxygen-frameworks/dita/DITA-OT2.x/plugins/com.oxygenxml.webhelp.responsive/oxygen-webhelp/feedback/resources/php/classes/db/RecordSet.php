<?php

/*

Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

*/

class RecordSet
{
    /**
     * Array containing connection information
     *
     * @var array
     */
    private $dbConnectionInfo;

    var $m_Conn;
    var $m_QueryResult;
    var $m_CurrentRecord;
    var $m_RowsCount;
    var $m_AffectedRows;

    var $m_IsValid = false;

    var $m_DBErrorNumber = 0; //no error
    var $m_DBErrorMessage = "";
    var $throwException;
    private $m_CurrentRow;

    /**
     * RecordSet Class
     *
     * @param array $_dbConnectionInfo
     * @param boolean $_compress
     * @param bool $throwException
     * @throws Exception
     */
    function __construct($_dbConnectionInfo, $_compress = false, $throwException = false)
    {
        $this->throwException = $throwException;
        if ($_dbConnectionInfo) {
            $this->dbConnectionInfo = $_dbConnectionInfo;
            $_name = $_dbConnectionInfo['dbName'];
            $_user = $_dbConnectionInfo['dbUser'];
            $_password = $_dbConnectionInfo['dbPassword'];
            $_host = $_dbConnectionInfo['dbHost'];

            $this->m_IsValid = true;
            $this->m_Conn = mysqli_init();

            if ($_compress) {
                if (!mysqli_options($this->m_Conn, MYSQLI_CLIENT_COMPRESS, true)) {
                    $this->m_IsValid = false;
                    if ($this->throwException) {
                        throw new Exception("r: Error:" . mysqli_errno($this->m_Conn) . "-" . $this->m_DBErrorMessage);
                    }
                }
            }

            if (!@mysqli_real_connect($this->m_Conn, $_host, $_user, $_password)) {
                $this->m_DBErrorNumber = mysqli_connect_errno();
                $this->m_DBErrorMessage = mysqli_connect_error();
                $this->m_IsValid = false;
            } else {
                $this->m_DBErrorNumber = mysqli_errno($this->m_Conn);
                $this->m_DBErrorMessage = mysqli_error($this->m_Conn);
            }

            if ($this->m_DBErrorNumber) {
                $this->m_IsValid = false;
                if ($this->throwException) {
                    throw new Exception("r: Error:" . $this->m_DBErrorNumber . "-" . $this->m_DBErrorMessage);
                }
            }

            if (strlen(trim($_name)) > 0) {
                $this->selectDb($_name);
            }
        } else {
            if ($this->throwException) {
                throw new Exception("r: DB Connection info ar not provided for RecordSet class!");
            }
        }
    }

    function runFile($file, $ignoreErrors = false)
    {
        if (file_exists($file)) {
            $f = fopen($file, "r");
            $sqlFile = fread($f, filesize($file));
            $sqlArray = explode(';', $sqlFile);
            $count = count($sqlArray);
            $i = 0;
            $err = 0;
            foreach ($sqlArray as $stmt) {
                $i++;
                if (trim($stmt) != "") {
                    $result = $this->Run($stmt);
                    if (!$result) {
                        $err++;
                        $this->m_DBErrorNumber = mysqli_errno($this->m_Conn);
                        if ($this->m_DBErrorNumber && !$ignoreErrors) {
                            $this->m_DBErrorMessage = mysqli_error($this->m_Conn);
                            $this->m_IsValid = false;
                            if ($this->throwException) {
                                throw new Exception("r: MySQL Error:" . $this->m_DBErrorNumber . "-"
                                    . $this->m_DBErrorMessage . "Running query='" . $stmt . "' " . $i . " form " . $file . " (Total of " . $count . " )");
                            }
                        }
                    }
                }
            }
        } else {
            if ($this->throwException) {
                throw new Exception("File :" . $file . " does not exist!");
            }
        }
    }

    function selectDb($dbName)
    {
        if (!empty($dbName) && $this->m_IsValid) {
            mysqli_select_db($this->m_Conn, $dbName);

            $this->m_DBErrorNumber = mysqli_errno($this->m_Conn);
            if ($this->m_DBErrorNumber) {
                $this->m_DBErrorMessage = mysqli_error($this->m_Conn);
                $this->m_IsValid = false;
                if ($this->throwException) {
                    throw new Exception("r: MySQL Error:" . $this->m_DBErrorNumber . "-" . $this->m_DBErrorMessage);
                }
            }
        }
    }

    /**
     * Open the record set for the specified query
     *
     * @param String $query
     * @return Number of rows returned by running the secified query
     * @throws Exception
     */
    function Open($query)
    {
        if ($this->m_IsValid) {
            $this->m_QueryResult = mysqli_query($this->m_Conn, $query);
        }
        if ($this->m_IsValid === false) {
            $this->m_RowsCount = -1;
        } else {
            $this->m_DBErrorNumber = mysqli_errno($this->m_Conn);
            $this->m_RowsCount = false;

            if ($this->m_DBErrorNumber) {
                $this->m_DBErrorMessage = mysqli_error($this->m_Conn);
                if ($this->throwException) {
                    throw new Exception("r: Error:" . $this->m_DBErrorNumber . "-" . $this->m_DBErrorMessage);
                }
            } else {
                $this->m_RowsCount = mysqli_num_rows($this->m_QueryResult);
                $this->m_DBErrorNumber = mysqli_errno($this->m_Conn);
                if ($this->m_DBErrorNumber) {
                    $this->m_DBErrorMessage = mysqli_error($this->m_Conn);
                    if ($this->throwException) {
                        throw new Exception("r: Error:" . $this->m_DBErrorNumber . "-" . $this->m_DBErrorMessage);
                    }
                }
            }
        }
        return $this->m_RowsCount;
    }


    function Run($ActionQuery)
    {
        $this->m_QueryResult = mysqli_query($this->m_Conn, $ActionQuery);
        if ($this->m_QueryResult === false) {
            $this->m_DBErrorNumber = mysqli_errno($this->m_Conn);
            $this->m_DBErrorMessage = mysqli_error($this->m_Conn);
            if ($this->throwException) {
                throw new Exception("Error:" . $this->m_DBErrorNumber . "-" . $this->m_DBErrorMessage);
            }
            $this->m_RowsCount = -1;
        } else {
            $this->m_DBErrorNumber = mysqli_errno($this->m_Conn);
            if ($this->m_DBErrorNumber) {
                $this->m_DBErrorMessage = mysqli_error($this->m_Conn);
                if ($this->throwException) {
                    throw new Exception("Error:" . $this->m_DBErrorNumber . "-" . $this->m_DBErrorMessage);
                }
            }
            $this->m_RowsCount = mysqli_affected_rows($this->m_Conn);

            $this->m_DBErrorNumber = mysqli_errno($this->m_Conn);
            if ($this->m_DBErrorNumber) {
                $this->m_DBErrorMessage = mysqli_error($this->m_Conn);
                if ($this->throwException) {
                    throw new Exception("Error:" . $this->m_DBErrorNumber . "-" . $this->m_DBErrorMessage);
                }
            }
        }
        return $this->m_RowsCount;
    }

    /**
     * Return the value for the specified field on the current row
     *
     * @param String $fieldName
     * @return String Field value
     */
    function Field($fieldName)
    {
        return $this->m_CurrentRow[$fieldName];
    }

    function IsValid()
    {
        return $this->m_IsValid;
    }

    /**
     * Snitize mysql strings
     *
     * @param String $text
     * @return string
     * @throws Exception
     */
    function sanitize($text)
    {
        $toReturn = $text;
        if ($this->dbConnectionInfo) {
            $_user = $this->dbConnectionInfo['dbUser'];
            $_password = $this->dbConnectionInfo['dbPassword'];
            $_host = $this->dbConnectionInfo['dbHost'];
            $newConn = @mysqli_connect($_host, $_user, $_password);
            if (!$newConn) {
                $this->m_DBErrorNumber = mysqli_connect_errno();
                $this->m_DBErrorMessage = mysqli_connect_error();
                if ($this->throwException) {
                    throw new Exception("Error:" . $this->m_DBErrorNumber . "-" . $this->m_DBErrorMessage);
                }
            } else {
                $toReturn = mysqli_real_escape_string($newConn, $toReturn);
            }
        } else {
            if ($this->throwException) {
                throw new Exception("r: DB Connection info ar not provided for RecordSet class!");
            }
        }
        return $toReturn;
    }

    /**
     * Sanitize value af an array
     *
     * @param array $array
     * @throws Exception
     * @return array sanitized
     */
    function sanitizeArray($array)
    {
        $toReturn = array();
        if ($this->m_IsValid) {
            foreach ($array as $key => $val) {
                $toReturn[$key] = mysqli_real_escape_string($this->m_Conn, $val);
            }
        } else {
            if ($this->throwException) {
                throw new Exception("r: No connection available in order to use sanitize");
            }
        }
        return $toReturn;
    }

    function MoveNext()
    {
        $this->m_CurrentRow = mysqli_fetch_array($this->m_QueryResult);
        if ($this->m_CurrentRow) {
            return 1;
        }
        return 0;
    }

    function getAssoc()
    {
        $row = mysqli_fetch_assoc($this->m_QueryResult);
        if ($row) {
            return $row;
        }
        return 0;
    }

    function Close()
    {
        if ($this->m_IsValid) {
            mysqli_close($this->m_Conn);
            $this->m_IsValid = false;
            $this->m_Conn = null;
        }
    }

    function __destruct()
    {
        if ($this->m_IsValid) {
            mysqli_close($this->m_Conn);
            $this->m_IsValid = false;
            $this->m_Conn = null;
        }
    }

}

?>
