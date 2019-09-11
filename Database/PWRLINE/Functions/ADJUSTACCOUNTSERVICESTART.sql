CREATE OR REPLACE function pwrline.AdjustAccountServiceStart(inUIDAccount IN NUMBER, inEffDate IN VARCHAR2) RETURN VARCHAR2 IS

	vResult	VARCHAR2(500);
	vCount	INTEGER;

BEGIN

	vResult := 'SUCCESS';

	vCount := 0;
	BEGIN
		SELECT COUNT(*) INTO vCount
			FROM pwrline.acctservicehist
			WHERE energized = 'E' AND stoptime IS NULL AND uidaccount = inUIDAccount;

		EXCEPTION WHEN OTHERS THEN
			vResult := 'ERROR Getting Record Count for First Usage!!!';
			RETURN vResult;
	END;

	IF vCount = 1 THEN
		BEGIN
			UPDATE acctservicehist
				SET starttime = TO_DATE(inEffDate, 'YYYYMMDD')
				WHERE uidaccount = inUIDAccount
					AND energized = 'E' AND stoptime IS NULL;

			COMMIT;

			EXCEPTION WHEN OTHERS THEN
				ROLLBACK;
				vResult := 'ERROR Updating ASH due to First Usage!!!' || SQLERRM;
				RETURN vResult;

		END;
	ELSE
		vResult := 'ERROR! More than one ASH for First Usage update!!!';
	END IF;

	RETURN vResult;

END;
/